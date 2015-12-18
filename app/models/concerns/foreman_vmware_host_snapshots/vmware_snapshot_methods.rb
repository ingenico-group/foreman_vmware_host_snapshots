module ForemanVmwareHostSnapshots
  module VmwareSnapshotMethods
    extend ActiveSupport::Concern

    def take_vm_snapshot(options = {})
      raise ArgumentError, "instance_uuid is a required parameter" unless options.key? 'instance_uuid'
      raise ArgumentError, "name is a required parameter" unless options.key? 'name'
      vm = client.send(:get_vm_ref, options['instance_uuid'])
      task = vm.CreateSnapshot_Task(
        :name => options['name'],
        :description => options['description'] || '',
        :memory => options['memory'] || true,
        :quiesce => options['quiesce'] || false
      )

      task.wait_for_completion

      # {
      #   'task_state' => task.info.state,
      #   'was_cancelled' => task.info.cancelled
      # }
      return task.info.state.to_s.downcase.include?("success")
    end

    def get_vm_snapshots(uuid)
      raise ArgumentError, "uuid is a required parameter" if uuid.to_s.blank?
      vm_snapshot_info = client.send(:get_vm_ref, uuid).snapshot

      return [] unless vm_snapshot_info
      @current_snapshot = (vm_snapshot_info.currentSnapshot ? vm_snapshot_info.currentSnapshot._ref : "")
      root_snapshots = vm_snapshot_info.rootSnapshotList.map do |snap|
        
        item = snapshot_info(snap, uuid)
            [
              item,
              list_child_snapshots(item)
            ]
      end

      root_snapshots.flatten.compact
    end
    def snapshot_info(snap_tree, uuid)
      {
        :name => snap_tree.name,
        :quiesced => snap_tree.quiesced,
        :description => snap_tree.description,
        :create_time => snap_tree.createTime.to_time,#.in_time_zone(Time.zone),
        :power_state => snap_tree.state,
        :ref => snap_tree.snapshot._ref,
        :mo_ref => snap_tree.snapshot,
        :tree_node => snap_tree,
        :parent_name => "",
        :current_snapshot => (@current_snapshot.to_s == snap_tree.snapshot._ref.to_s)
      }
    end

    def list_child_snapshots(snapshot)
      snapshot_tree_node = Hash === snapshot ?
            snapshot[:tree_node] : snapshot
      child_snapshots = snapshot_tree_node.childSnapshotList.map do |snap|
        item = child_snapshot_info(snap, snapshot)
        [
          item,
          list_child_snapshots(item)
        ]
      end

      child_snapshots.flatten.compact
    end        

    def child_snapshot_info(snap_tree, parent_snap)
      {
        :name => snap_tree.name,
        :quiesced => snap_tree.quiesced,
        :description => snap_tree.description,
        :create_time => snap_tree.createTime.to_time,#.in_time_zone(Time.zone),
        :power_state => snap_tree.state,
        :ref => snap_tree.snapshot._ref,
        :mo_ref => snap_tree.snapshot,
        :tree_node => snap_tree,
        :parent_name => parent_snap[:name],
        :current_snapshot => (@current_snapshot.to_s == snap_tree.snapshot._ref.to_s)
      }
    end

    def find_vm_snapshot(uuid, ref)
      raise ArgumentError, "uuid is a required parameter" if uuid.to_s.blank?
      raise ArgumentError, "ref is a required parameter" if ref.to_s.blank?
      for snapshot in get_vm_snapshots(uuid)
        return snapshot if snapshot[:ref] == ref.to_s.strip
      end
      return nil      
    end

    def revert_to_vm_snapshot(uuid, ref)
      raise ArgumentError, "uuid is a required parameter" if uuid.to_s.blank?
      raise ArgumentError, "ref is a required parameter" if ref.to_s.blank?
      for snapshot in get_vm_snapshots(uuid)
        if snapshot[:ref] == ref.to_s.strip
          task = snapshot[:mo_ref].RevertToSnapshot_Task(:removeChildren => true)
          task.wait_for_completion
          return task.info.state.to_s.downcase.include?("success")
        end
      end
      return false
    end

    def delete_vm_snapshot(uuid, ref)
      raise ArgumentError, "uuid is a required parameter" if uuid.to_s.blank?
      raise ArgumentError, "ref is a required parameter" if ref.to_s.blank?
      for snapshot in get_vm_snapshots(uuid)
        if snapshot[:ref] == ref.to_s.strip
          task = snapshot[:mo_ref].RemoveSnapshot_Task(:removeChildren => true)
          task.wait_for_completion
          return task.info.state.to_s.downcase.include?("success")
        end
      end
      return false
    end

    def delete_all_vm_snapshot(uuid)
      raise ArgumentError, "uuid is a required parameter" if uuid.to_s.blank?
      vm = client.send(:get_vm_ref, uuid)
      task = vm.RemoveAllSnapshots_Task
      task.wait_for_completion
      return task.info.state.to_s.downcase.include?("success")
    end

  end
end
