module VmwareSnapshotsHelper

  def snapshot_state(state)
    if state == 'PAUSED'
      ' ' + _("Paused")
    else
      state.to_s.downcase == "poweredon" ? _("On") : _("Off")
    end
  end

  def snapshot_power_class(state)
    "class='label #{(state.to_s.downcase == "poweredon") ? "label-success" : "label-default"}'".html_safe
  end

end