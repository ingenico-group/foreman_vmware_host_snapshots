var do_load_snapshots = true
function load_host_snapshots_popup() {
  $("#vmware_host_snapshots_popup").modal('show');
  setTimeout(function() {load_host_snapshots()}, 500);
}

function load_host_snapshots(){
  if (do_load_snapshots != true)
    return false
  do_load_snapshots = false
  $('#vmware_host_snapshots_popup #snapshots').html("<p id='spinner'><img src='/assets/spinner.gif' alt='Spinner'>Loading snapshots information ...</p>")
  $.ajax({
    type:'GET',
    url: $("#host_snapshots_btn").attr('data-url'),
    // dataType:'json',
    // contentType:"application/json",
    
    success: function(response){
      do_load_snapshots = false
      $('#vmware_host_snapshots_popup #snapshots').html(response);
      $('[rel="twipsy"]').tooltip();
    },
    error: function(request, status, error) {
      $('#vmware_host_snapshots_popup #snapshots').html(Jed.sprintf(__("Error: %s"), error))
    },
  });
}

// $(document).on('submit',"[data-submit='vmware_snapshot_form11']", function() {
//   // onContentLoad function clears any un-wanted parameters from being sent to the server by
//   // binding 'click' function before this submit. see '$('form').on('click', 'input[type="submit"]', function()'
//   //submit_vmware_snapshot();
//   return false;
// });

function submit_vmware_snapshot(){
  $('#add_snapshot_status').html("");
  if($('#snapshot_name').val() == 0){
    $('#add_snapshot_status').html("<div class='text-danger'>Name is required</div>");
    return false
  }else if($('#snapshot_description').val() == 0){
    $('#add_snapshot_status').html("<div class='text-danger'>Description is required</div>");
    return false
  }
  var btn = $('#take_snapshot_btn');
  var url = $('[data-submit=vmware_snapshot_form]').attr('action');
  $("body").css("cursor", "progress");
  btn.button('loading');
  $('#add_snapshot_status').html("<p id='spinner'><img src='/assets/spinner.gif' alt='Spinner'> <span class='text-warning'>Please wait, this may take some time ...</span></p>")
  $.ajax({
    type:'POST',
    url: url,
    dataType: 'json',
    contentType:"application/json; charset=utf-8",
    data: JSON.stringify({name: $('#snapshot_name').val(), description: $('#snapshot_description').val()}),
    success: function(response){
      $('#snapshot_name').val("");
      $('#snapshot_description').val("");
      do_load_snapshots = true
      if(response["message"] != ""){
        $('#add_snapshot_status').html("<div class='text-success'>"+response["message"]+"</div>");
      }else{
        $('#add_snapshot_status').html("<div class='text-success'>Successfully taken snapshot</div>");
      }
    },
    error: function(response, status, error){
      $("body").css("cursor", "auto");
      //JSON.parse(response)
      resp = JSON.parse(response.responseText)
      if(resp["error"] != ""){
        $('#add_snapshot_status').html("<div class='text-danger'>"+resp["error"]+"</div>");
      }else{
        $('#add_snapshot_status').html("<div class='text-danger'>Failed to take snapshot. Please try again</div>");
      }
    },
    complete: function(){
      $("body").css("cursor", "auto");
      btn.button('reset');
    }
  });
  return false;
}

function revert_snapshot(snapshot){
  var snapshot_action_spinner = $("#"+snapshot+"-spinner")
  snapshot_action_spinner.show()
  $.ajax({
    type:'PUT',
    url: $('#'+snapshot).attr('revert-snapshot-url'),
    dataType: 'json',
    contentType:"application/json; charset=utf-8",
    success: function(response){
      update_current_snapshot(snapshot)
      if(response["message"] != ""){
        alert(response["message"]);
      }else{
        alert("Successfully reverted ");
      }
    },
    error: function(response, status, error){
      resp = JSON.parse(response.responseText)
      if(resp["error"] != ""){
        alert(resp["error"]);
      }else{
        alert("Failed to revert. Please try again");
      }
    },
    complete: function(){
      snapshot_action_spinner.hide()
    }
  });
}
function delete_snapshot(snapshot){
  var snapshot_action_spinner = $("#"+snapshot+"-spinner")
  snapshot_action_spinner.show()
  $.ajax({
    type:'DELETE',
    url: $('#'+snapshot).attr('delete-snapshot-url'),
    dataType: 'json',
    contentType:"application/json; charset=utf-8",
    success: function(response){
      //$("#"+snapshot).remove()
      if(response["message"] != ""){
        alert(response["message"]);
      }else{
        alert("Successfully reverted ");
      }
      do_load_snapshots = true
      load_host_snapshots()
    },
    error: function(response, status, error){
      resp = JSON.parse(response.responseText)
      if(resp["error"] != ""){
        alert(resp["error"]);
      }else{
        alert("Failed to revert. Please try again");
      }
    },
    complete: function(){
      snapshot_action_spinner.hide()
    }
  });
}

function update_current_snapshot(snapshot){
  $(".current-snapshot").removeAttr("rel");
  var current_snapshot_title = $(".current-snapshot").attr("data-original-title")
  var current_snapshot_icon = $(".glyphicon-record")[0].outerHTML
  $(".current-snapshot").removeAttr("data-original-title")
  $(".glyphicon-record").remove()
  $(".current-snapshot").removeClass("current-snapshot")
  $("#"+snapshot).addClass("current-snapshot")
  $("#"+snapshot).attr("data-original-title", current_snapshot_title)
  $("#"+snapshot).attr("rel", "twipsy")

  $("#"+snapshot+" td:first").html(current_snapshot_icon + $("#"+snapshot+" td:first").html())
  $('[rel="twipsy"]').tooltip();
}