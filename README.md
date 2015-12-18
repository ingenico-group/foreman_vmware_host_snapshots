# ForemanVmwareHostSnapshots

This plugin will provide snapshot management(create/list/revert/delete snapshots) to hosts created in VMware compute resource

## Installation

See [How_to_Install_a_Plugin](http://projects.theforeman.org/projects/foreman/wiki/How_to_Install_a_Plugin)
for how to install Foreman plugins

### Red Hat, CentOS, Fedora, Scientific Linux (rpm)

Set up the repo as explained in the link above, then run

    # yum install ruby193-rubygem-foreman_vmware_host_snapshots

### Bundle (gem)

Add the following to bundler.d/Gemfile.local.rb in your Foreman installation directory (/usr/share/foreman by default)

    $ gem 'foreman_vmware_host_snapshots'

Then run `bundle install`

## Usage

In host details page, there is a button "Snapshots" in left side under Details section. When user click on "Snapshots" button one popup box will appear with two subtabs "Snapshots" and "Take Snapshot". Snapshots subtab will display list of snapshots take for that host and Take Snapshot subtab will display form to take snapshot

## Screenshots

![Snapshots button in host show page](https://raw.githubusercontent.com/ingenico-group/screenshots/master/foreman_vmware_host_snapshots/snapshots_button_in_server_details_page.png)

![Snapshots popup](https://raw.githubusercontent.com/ingenico-group/screenshots/master/foreman_vmware_host_snapshots/snapshots_popup.png)

![Take Snapshot form](https://raw.githubusercontent.com/ingenico-group/screenshots/master/foreman_vmware_host_snapshots/take_snapshot_form.png)

## APIs

### List all Snapshots of VMware Host

```bash
curl -k -u admin:changeme -H 'Accept: application/json'\
  https://foreman.example.com/api/v2/hosts/:host_id/vmware_snapshots 
```

API response

```yaml
[{"name":"nagarjuna","description":"testing snapshot","create_time":"2015-11-27T15:19:23+05:30","power_state":"poweredOn","ref":"snapshot-324","parent_name":"","current_snapshot":false
},
{"name":"nagarjuna1","description":"testing snapshot2","create_time":"2015-11-27T15:22:06+05:30","power_state":"poweredOn","ref":"snapshot-325","parent_name":"nagarjuna","current_snapshot":false
},
{"name":"nagarjuna3","description":"testing snapshot3","create_time":"2015-11-27T16:27:30+05:30","power_state":"poweredOn","ref":"snapshot-326","parent_name":"nagarjuna1","current_snapshot":false
},
{"name":"nagarjuna4","description":"nagarjuna4","create_time":"2015-11-30T11:43:38+05:30","power_state":"poweredOn","ref":"snapshot-327","parent_name":"nagarjuna3","current_snapshot":false
}]
```

### Create Snapshot of Host

Create Snapshot API will accept following parameters

	* name: Mandatory. This is the name of the Snapshot
	* description: Mandatory. Information about the Snapshot

```bash
curl -k -u admin:changeme -H 'Content-Type: application/json'\
  https://foreman.example.com/api/v2/hosts/:host_id/vmware_snapshots -d '{"name": "testing-snapshot", "description": "Testing"}'
```

API response

```yaml
{"message":"Succefully taken snapshot"}

OR

{"error":"Failed to take snapshot"}
```
### Get Snapshot of Host

```bash
curl -k -u admin:changeme -H 'Content-Type: application/json'\
  https://foreman.example.com/api/v2/hosts/:host_id/vmware_snapshots/:ref
```

API response

```yaml
{"name":"nagarjuna","description":"testing snapshot","create_time":"2015-11-27T15:19:23+05:30","power_state":"poweredOn","ref":"snapshot-324","parent_name":"","current_snapshot":false
}
```

### Revert to specific Snapshot


```bash
curl -k -u admin:changeme -H 'Content-Type: application/json'\
  https://foreman.example.com/api/v2/hosts/:host_id/vmware_snapshots/:ref/revert -X PUT
```

API response

```yaml
{"message":"Succefully reverted snapshot"}

OR

{"error":"Failed to revert snapshot"}
```

### Delete Snapshot

```bash
curl -k -u admin:changeme -H 'Content-Type: application/json'\
  https://foreman.example.com/api/v2/hosts/:host_id/vmware_snapshots/:ref -X DELETE
```

API response

```yaml
{"message":"Succefully deleted snapshot"}

OR

{"error":"Failed to delete snapshot"}
```

## Contributing

Fork and send a Pull Request. Thanks!

## License

GPLv3


