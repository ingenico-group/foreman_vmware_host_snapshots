module ForemanVmwareHostSnapshots
	module HostSnapshotMethods
		extend ActiveSupport::Concern

		def is_vmware_snapshots_enabled?
			return ["vmware"].include?(provider.to_s.downcase)
		end

		def vmware_snapshots
			return compute_resource.get_vm_snapshots(uuid).map{|sn| snapshot_fields(sn)}.compact
			# return [{:name=>"nagarjuna", :description=>"testing snapshot", :create_time=>"Fri, 27 Nov 2015 09:49:23 UTC +00:00".to_time.in_time_zone("Chennai"), :power_state=>"poweredOn", :ref=>"snapshot-324", :parent_name=>"", :current_snapshot=>false}, {:name=>"nagarjuna1", :description=>"testing snapshot2", :create_time=>"Fri, 27 Nov 2015 09:52:06 UTC +00:00".to_time.in_time_zone("Chennai"), :power_state=>"poweredOn", :ref=>"snapshot-325", :parent_name=>"nagarjuna", :current_snapshot=>false}, {:name=>"nagarjuna3", :description=>"testing snapshot3", :create_time=>"Fri, 27 Nov 2015 10:57:30 UTC +00:00".to_time.in_time_zone("Chennai"), :power_state=>"poweredOn", :ref=>"snapshot-326", :parent_name=>"nagarjuna1", :current_snapshot=>false}, {:name=>"nagarjuna4", :description=>"nagarjuna4", :create_time=>"Mon, 30 Nov 2015 06:13:38 UTC +00:00".to_time.in_time_zone("Chennai"), :power_state=>"poweredOn", :ref=>"snapshot-327", :parent_name=>"nagarjuna3", :current_snapshot=>true}]
		end

		def take_vmware_snapshots(snapshot_name, snapshot_description)
			return {:error => "Name is required"} if snapshot_name.to_s.blank?
			return {:error => "Description is required"} if snapshot_description.to_s.blank?
			return compute_resource.take_vm_snapshot({'instance_uuid' => uuid, 'name' => snapshot_name, 'description' => snapshot_description}) ? {:message => "Succefully taken snapshot"} : {:error => "Failed to take snapshot"}
		end

		def find_vmware_snapshot(ref)
			return snapshot_fields(compute_resource.find_vm_snapshot(uuid, ref))
		end

		def revert_to_vmware_snapshot(ref)
			# return true ? {:message => "Succefully reverted snapshot"} : {:error => "Failed to revert snapshot"}
			return compute_resource.revert_to_vm_snapshot(uuid, ref) ? {:message => "Succefully reverted snapshot"} : {:error => "Failed to revert snapshot"}
		end

		def delete_vmware_snapshot(ref)
			# return true ? {:message => "Succefully deleted snapshot"} : {:error => "Failed to delete snapshot"}
			return compute_resource.delete_vm_snapshot(uuid, ref) ? {:message => "Succefully deleted snapshot"} : {:error => "Failed to delete snapshot"}
		end

		def delete_all_vmware_snapshot
			return compute_resource.delete_all_vm_snapshot(uuid) ? {:message => "Succefully deleted all snapshots"} : {:error => "Failed to delete all snapshots"}
		end

		def snapshot_fields(snapshot)
			snapshot.is_a?(Hash) ? snapshot.slice(:name, :description, :create_time, :power_state, :ref, :parent_name, :current_snapshot) : snapshot
		end

	end
end