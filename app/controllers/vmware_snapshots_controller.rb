
class VmwareSnapshotsController < ApplicationController

  before_filter :find_host

  # before_filter :find_resource

  def index
  	@snapshots = @host.vmware_snapshots
  	render :partial => "list"
  end

  def find_host
  	not_found and return false if params[:host_id].blank?
  	@host = Host.find(params[:host_id]) if Host::Managed.respond_to?(:authorized) and Host::Managed.authorized("view_host", Host::Managed)
  	not_found and return(false) unless @host
  	unless @host.is_vmware_snapshots_enabled?
  		render :text => "Host compute resource is not VMware"
  		return 
  	end
  end
  
end
