Deface::Override.new(
      :virtual_path => "hosts/show",
      :name => "vmware_host_snapshots_button",
      :insert_bottom => "table#details_table tr td",
      :partial  => "/foreman_vmware_host_snapshots/hosts/snapshots_button"
      # :text => " <a title='' data-id='aid_hosts_hiera_lookup' data-url='#{hiera_lookup_host_path(@host)}' class='btn btn-default' onclick='load_host_hiera_lookup_popup(\"<%= @host %>\")' data-original-title='Lookup hiera variable value'>Hiera Lookup</a>"
    )

Deface::Override.new(
	:virtual_path => "hosts/show",
	:name => "snapshots_popup",
	:insert_after => "table",
	:partial  => "/foreman_vmware_host_snapshots/hosts/snapshots_model_popup"
	)