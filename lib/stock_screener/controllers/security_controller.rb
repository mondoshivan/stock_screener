class SecurityController < Controller

  use AssetHandler
  helpers UsersHelpers
  helpers SearchHelpers
  helpers SecurityHelpers
  helpers StockScreenerHelpers

  #################
  # Configuration #
  #################

  configure do
    # Google Chart Options
    set :google_chart_config,  {
        'chartArea' => {'width'=> '80%', 'height' => '80%'},
        'curveType' => 'none', # none or function
        'enableInteractivity' => true, # true, false
        'explorer' => nil, # { 'actions' => ['dragToZoom', 'rightClickToReset'] }, # nil, {}
        'pointSize' => 0,
        'pointsVisible' => false,
        'trendlines' => {
            0 => {
                'type' => 'polynomial', #  linear, polynomial, and exponential.
                'color' => 'green',
                'lineWidth' => 3,
                'opacity' => 0.3,
                'showR2' => true,
                'visibleInLegend' => true,
                'pointsVisible' => false,
                'enableInteractivity' => false
            }
        },
        'vAxis' => {
            'gridlines' => {
                'color' => '#333',
                'count' => 8
            }
        }
    }
  end


  ###########
  # Helpers #
  ###########

  def interval_selected?(interval)
    return interval == params[:period] ? 'selected' : nil
  end

  def get_change()
    if @data.change_in_percent < 0
      return "#{get_string_from_number(@data.change)} (#{get_string_from_number(@data.change_in_percent)} %)"
    elsif @data.change_in_percent > 0
      return "#{'+' if @data.change > 0 }#{get_string_from_number(@data.change)} (#{'+' if @data.change > 0}#{get_string_from_number(@data.change_in_percent)} %)"
    else
      return "#{'%.2f' % @data.change_in_percent.to_f}%"
    end
  end


  ##################
  # Route Handlers #
  ##################

  get '/' do
    @security = find_security_with_id(params[:security_id])

    # error condition
    halt 404, slim(:not_found) unless @security

    # get data
    tickers = [@security.ticker.name]
    @data = get_all_quotes(tickers)[0]
    @data.to_h.each {|k,v| logger.info "#{k}: #{v}"}

    # get history
    @periods = {
        '1M' => 30,
        '6M' => 30 * 6,
        '1Y' => 365,
        'Max' => 0
    }

    default = @periods['1Y']
    @history = get_history(
        @security.ticker.name,
        @periods[params[:period]] || default
    )

    padding = 0.01
    @min = @history.values.min * (1 - padding)
    @max = @history.values.max * (1 + padding)

    slim :security
  end

  get '/:security_id/last-price' do
    logged_in!
    content_type :json

    @security = find_security_with_id(params[:security_id])
    halt 404 unless @security

    tickers = [@security.ticker.name]
    @data = get_quotes(
        tickers,
        [
            :change,
            :change_in_percent,
            :last_trade_price
        ]
    )
    @data = @data[0]

    return @data.to_h.to_json
  end

  get '/:security_id/income-statement/:date' do
    content_type :json

    @security = find_security_with_id(params[:security_id])
    halt 404 unless @security
    halt 404 unless params[:date]
    halt 404 if params[:date].downcase == 'null'

    begin
      date = Date.strptime(params[:date], '%d.%m.%Y')
    rescue ArgumentError
      halt 404
    end

    income_statement = @security.income_statements.first(:date => date)
    return income_statement.to_json
  end

  get '/:security_id/balance-sheet/:date' do
    content_type :json

    @security = find_security_with_id(params[:security_id])
    halt 404 unless @security
    halt 404 unless params[:date]
    halt 404 if params[:date].downcase == 'null'

    begin
      date = Date.strptime(params[:date], '%d.%m.%Y')
    rescue ArgumentError
      halt 404
    end

    balance_sheet = @security.balance_sheets.first(:date => date)
    return balance_sheet.to_json
  end

  put '/trade' do
    logged_in!
    @security = find_security_with_id(params[:security_id])

    # error condition
    halt 404, slim(:not_found) unless @security
    halt 422, slim(:unprocessable) unless params[:volume].to_i != 0

    tickers = [@security.ticker.name]
    @data = get_last_price(tickers)
    @data = @data[0]

    Item.create(
            security: find_security_with_id(params[:security_id]),
            user: get_user_with_id(session[:user_id]),
            volume: params[:volume].to_i,
            price: @data[:last_trade_price],
            signed_at: DateTime.now
    )

    flash[:notice] = "Added to your portfolio!"
    redirect to("/?security_id=#{@security.id}")
  end

end