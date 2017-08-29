getThreads = ->
  $.ajax
    type: 'GET'
    url: "/threads/running"
    dataType: "json"
    error: (jqXHR, textStatus, errorThrown) ->
      console.log("AJAX Error: #{textStatus}")
    success: (data, textStatus, jqXHR) ->
      return if jQuery.isEmptyObject(data)
      $('#threads').empty()
      threads = for i, thread of data
        $('#threads').append(
          "<div class=\'thread\'><h2> " + thread['name'] + "</h2><span>" + thread['controller'] + "</span></div>\n</div>")


$(document).ready ->
  getThreads()
  setInterval () ->
    getThreads()
  , 5000