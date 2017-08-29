
pulsate = (element) ->
  $(element || this).delay(150).fadeOut(500).delay(150).fadeIn(500, pulsate);

getThreads = ->
  $.ajax
    type: 'GET'
    url: "/threads/running"
    dataType: "json"
    error: (jqXHR, textStatus, errorThrown) ->
      console.log("AJAX Error: #{textStatus}")
    success: (data, textStatus, jqXHR) ->
      $('#threads').empty()
      threads = for i, thread of data
        $('#threads').append(
          "<div class=\'thread\'><h2> " + thread['name'] + "</h2><span>" + thread['controller'] + "</span></div>\n</div>")

$(document).ready ->
  getThreads()
  pulsate('#threads')

  setInterval () ->
    getThreads()

  , 5000


