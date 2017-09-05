attributes = {}

$ ->
  dialog_width = $('#content').width() * 0.8
  $( "#dialog" ).dialog({autoOpen: false, width: dialog_width});
  $( "#dialog-tabs" ).tabs();

$(document).ready ->
  $.ajax
    type: 'GET'
    url: "/search/attributes"
    dataType: "json"
    error: (jqXHR, textStatus, errorThrown) ->
      console.log("AJAX Error: #{textStatus}")
    success: (data, textStatus, jqXHR) ->
      attributes = data

$(document).on "click","#query-form button[class*='remove-attribute']", (event) ->
  event.preventDefault();
  $(this).closest(".attribute-row").remove()

$(document).on "click","#query-form button[id='add-attribute']", (event) ->
  event.preventDefault();
  $( "#dialog" ).dialog( "open" );

$(document).on "click",".dialog-item", (event) ->
  attribute_name = $(this).text()
  for group_type, group_values of attributes
    for attribute_type, attr_values of group_values.attributes
      if attr_values.name == attribute_name
        name = attr_values.name
        $('#attributes-added').append('<div class="attribute-row"><button class="remove-attribute">-</button><input name="attr_'+attribute_type+'_min" placeholder="min"><span>'+name+'</span><input name="attr_'+attribute_type+'_max" placeholder="max"></div>')
        $( "#dialog" ).dialog( "close" );
        $('button.remove-attribute').button()
        return
