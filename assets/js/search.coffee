

$ ->
  $('#searching').on "input", (event) ->
    input = $(this).val()

    $.ajax
      type: 'GET'
      url: "/search/tickers?input=" + input
      dataType: "json"
      error: (jqXHR, textStatus, errorThrown) ->
        console.log("AJAX Error: #{textStatus}")
      success: (data, textStatus, jqXHR) ->
        $( "#searching" ).autocomplete({source: data});