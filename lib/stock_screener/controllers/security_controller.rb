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

    set :income_statement_groups, {
        :revenue => [
            :total_revenue,
            :cost_of_revenue,
            :gross_profit
        ],
        :operating_expenses => [
            :research_development,
            :selling_general_and_administrative,
            :non_recurring,
            :others,
            :total_operating_expenses,
            :operating_income_or_loss
        ],
        :income_from_continuing_operations => [
            :total_other_income_expenses_net,
            :earnings_before_interest_and_taxes,
            :interest_expense,
            :income_before_tax,
            :income_tax_expense,
            :minority_interest,
            :net_income_from_continuing_ops
        ],
        :non_recurring_events => [
            :discontinued_operations,
            :extraordinary_items,
            :effect_of_accounting_changes,
            :other_items
        ],
        :net_income => [
            :net_income,
            :preferred_stock_and_other_adjustments,
            :net_income_applicable_to_common_shares
        ]
    }

    set :balance_sheet_groups, {
        :current_assets => [
            :cash_and_cash_equivalents,
            :short_term_investments,
            :net_receivables,
            :inventory,
            :other_current_assets,
            :total_current_assets,
            :long_term_investments,
            :property_plant_and_equipment,
            :goodwill,
            :intangible_assets,
            :accumulated_amortization,
            :other_assets,
            :deferred_long_term_asset_charges,
            :total_assets
        ],
        :current_liabilities => [
            :accounts_payable,
            :short_current_long_term_debt,
            :other_current_liabilities,
            :total_current_liabilities,
            :long_term_debt,
            :other_liabilities,
            :deferred_long_term_liability_charges,
            :minority_interest,
            :negative_goodwill,
            :total_liabilities
        ],
        :stockholders_equity => [
            :misc_stocks_options_warrants,
            :redeemable_preferred_stock,
            :preferred_stock,
            :common_stock,
            :retained_earnings,
            :treasury_stock,
            :capital_surplus,
            :other_stockholder_equity,
            :total_stockholder_equity,
            :net_tangible_assets
        ]
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

  def sym_to_string(sym)
    return sym.to_s.gsub('_', ' ').capitalize
  end


  ##################
  # Route Handlers #
  ##################

  get '/' do
    start = Time.now
    @security = find_security_with_id(params[:security_id])
    logger.info "find security in DB: #{Time.now - start}"

    # error condition
    halt 404, slim(:not_found) unless @security

    # get data
    start = Time.now
    tickers = [@security.ticker.name]
    @data = get_all_quotes(tickers)[0]
    logger.info "get all quotes: #{Time.now - start}"

    # get history
    @periods = {
        '1M' => 30,
        '6M' => 30 * 6,
        '1Y' => 365,
        'Max' => 0
    }

    start = Time.now
    interval = {
        '1M' => '1d',
        '6M' => '1d',
        '1Y' => '1wk',
        'Max' => '1mo'
    }
    @history = get_history(
        @security.ticker.name,
        @periods[params[:period]] || @periods['1Y'],
        interval[params[:period]] || interval['1Y']
    )
    logger.info "get history: #{Time.now - start}"

    @history.each do |date, values|
      @history[date] = values[:close_value]
      logger.info "#{date}: #{values[:close_value]}"
    end

    padding = 0.05
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