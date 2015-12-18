module Api
  module V2
    class VmwareSnapshotsController < V2::BaseController

      # include Api::Version2

      
      before_filter :find_required_nested_object
      
      # before_filter :find_resource
      before_filter :check_host_compute_resource

      api :GET, "hosts/:host_id/vmware_snapshots/", N_("List all Snapshots of given Host")
      param :host_id, :identifier_dottable, :required => true
      def index
        @snapshots = @nested_obj.vmware_snapshots
        process_response(true, @snapshots)
      end

      api :POST, "/hosts/:host_id/vmware_snapshots/", N_("Create a Host Snapshot")
      param :host_id, :identifier_dottable, :required => true
      param :name, String, :required => true
      param :description, String, :required => true, :desc => N_("Additional information about this Snapshot")

      def create
        create_status = @nested_obj.take_vmware_snapshots(params[:name], params[:description])
        # process_response(true, create_status)
        if create_status[:error].nil?
          render :json => create_status, :status => :ok
        else
          render :json => create_status, :status => :unprocessable_entity
        end
      end

      api :GET, "/hosts/:host_id/vmware_snapshots/:id", "Show a Host Snapshot"
      param :host_id, :identifier_dottable, :required => true
      param :id, :identifier_dottable, :required => true

      def show
        snapshot = @nested_obj.find_vmware_snapshot(params[:id])
        # process_response(true, snapshot)
        if snapshot
          render :json => snapshot, :status => :ok
        else
          render :json => {"error" => "Snapshot not found by ref '#{params[:id]}'"}, :status => :not_found
        end
      end

      api :PUT, "/hosts/:host_id/vmware_snapshots/:id/revert", N_("Revert to a Host Snapshot")
      param :host_id, :identifier_dottable, :required => true
      param :id, :identifier_dottable, :required => true

      def revert
        status = @nested_obj.revert_to_vmware_snapshot(params[:id])
        # process_response(status[:error].nil?, status)
        if status[:error].nil?
          render :json => status, :status => :ok
        else
          render :json => status, :status => :unprocessable_entity
        end
      end

      api :DELETE, "/hosts/:host_id/vmware_snapshots/:id", N_("Delete a Host Snapshot")
      param :host_id, :identifier_dottable, :required => true
      param :id, :identifier_dottable, :required => true

      def destroy
        status = @nested_obj.delete_vmware_snapshot(params[:id])
        # process_response(status[:error].nil?, status)
        if status[:error].nil?
          render :json => status, :status => :ok
        else
          render :json => status, :status => :unprocessable_entity
        end
      end

      api :DELETE, "/hosts/:host_id/vmware_snapshots/destroy_all", N_("Delete all Host Snapshots")
      param :host_id, :identifier_dottable, :required => true

      def destroy_all
        status = @nested_obj.delete_all_vmware_snapshot
        # process_response(status[:error].nil?, status)
        if status[:error].nil?
          render :json => status, :status => :ok
        else
          render :json => status, :status => :unprocessable_entity
        end
      end      

      def resource_name
        "Host"
      end      
       
      private

      def check_host_compute_resource
        not_found("Resource Host not found by id '#{params[:host_id]}'") and return(false) unless @nested_obj
        process_response(true, {:error => {:message => "Host compute resource is not VMware"}}) and return unless @nested_obj.is_vmware_snapshots_enabled?
      end

      def action_permission
        case params[:action]
          when 'revert'
            :revert
          when 'destroy_all'
            :destroy_all
          else
            super
        end
      end

      def allowed_nested_id
        %w(host_id)
      end

    end
  end
end

