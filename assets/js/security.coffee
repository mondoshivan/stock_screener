$ ->
  $( "#select-income-date" ).selectmenu();
  $( "#select-balance-date" ).selectmenu();

$ ->
  $("input.volume").on "input", ->
    volume = $(this).val()
    if isNaN(volume) == false && volume != ''
      price = parseFloat($('#last-price').text().replace(',','.'))
      volume = parseInt(volume)
      value = price * volume
      $("span.volume").text(value.toFixed(2))
    else
      $("span.volume").text('')

$ ->
  $("button.buy").on "click", (event) ->
    event.preventDefault()
    text = $('input.volume').val()
    console.log(text)
    if isNaN(text)
      alert("Illegal Value!")
    else
      $( "form.buy" ).submit();

$(document).ready ->
  setInterval () ->
    url = new URL(window.location.href)
    security_id = url.searchParams.get("security_id")

    $.ajax
      type: 'GET'
      url: "/security/#{security_id}/last-price"
      dataType: "json"
      error: (jqXHR, textStatus, errorThrown) ->
        console.log("AJAX Error: #{textStatus}")
      success: (data, textStatus, jqXHR) ->
        change = parseFloat(data.change).toFixed(2)
        change_in_percent = parseFloat(data.change_in_percent).toFixed(2)
        last_price = parseFloat(data.last_trade_price)
        page_price = parseFloat($('#last-price').text().replace(',','.'))

        if last_price != page_price
          sign = if change > 0 then '+' else ''
          color = 'green' if change > 0
          color = 'red' if change < 0
          change = change.toString().replace('.',',')
          change_in_percent = change_in_percent.toString().replace('.',',')
          changeStr = "#{sign}#{change} (#{sign}#{change_in_percent} %)"
          lastPriceStr = last_price.toString().replace('.',',')
          $('#changes').text(changeStr)
          $('#last-price').text(lastPriceStr)
          $('#changes').removeClass('green red')
          $('#changes').addClass(color)
          $('#effect').effect 'highlight', {color: '#696969'}, 500, ->
            setTimeout ->
              $( "#effect" );
            , 1000

  , 5000

getIncomeStatement = (date) ->
  return if date == null
  url = new URL(window.location.href)
  security_id = url.searchParams.get("security_id")

  $.ajax
    type: 'GET'
    url: "/security/#{security_id}/income-statement/#{date}"
    dataType: "json"
    error: (jqXHR, textStatus, errorThrown) ->
      console.log("AJAX Error: #{textStatus}")
    success: (data, textStatus, jqXHR) ->
      skip = ['security_id', 'id', 'period', 'date']
      for name, value of data
        continue if name in skip
        value = if value == null then '' else value
        $("##{name}").text(value)

getBalanceSheet = (date) ->
  return if date == null
  url = new URL(window.location.href)
  security_id = url.searchParams.get("security_id")

  $.ajax
    type: 'GET'
    url: "/security/#{security_id}/balance-sheet/#{date}"
    dataType: "json"
    error: (jqXHR, textStatus, errorThrown) ->
      console.log("AJAX Error: #{textStatus}")
    success: (data, textStatus, jqXHR) ->
      console.log(data)

      skip = ['security_id', 'id', 'period', 'date']
      for name, value of data
        continue if name in skip
        value = if value == null then '' else value
        $("##{name}").text(value)

$ ->
  $('#select-income-date').on "selectmenuchange", (event) ->
    date = $('#select-income-date').val()
    getIncomeStatement(date)

$ ->
  $('#select-balance-date').on "selectmenuchange", (event) ->
    date = $('#select-balance-date').val()
    getBalanceSheet(date)

$(document).ready ->
  date = $('#select-income-date').val()
  getIncomeStatement(date)

  date = $('#select-balance-date').val()
  getBalanceSheet(date)
