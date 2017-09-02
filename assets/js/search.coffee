
$(document).ready ->

  $.ajax
    type: 'GET'
    url: "/search/tickers"
    dataType: "json"
    error: (jqXHR, textStatus, errorThrown) ->
      console.log("AJAX Error: #{textStatus}")
    success: (data, textStatus, jqXHR) ->
      $( "#searching" ).autocomplete({source: data});