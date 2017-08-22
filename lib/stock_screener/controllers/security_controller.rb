class SecurityController < Controller

  use AssetHandler
  helpers SearchHelpers
  helpers SecurityHelpers
  helpers StockScreenerHelpers


  ###########
  # Helpers #
  ###########

  def interval_selected?(interval)
    return interval == params[:period] ? 'selected' : nil
  end

  def get_change()
    if @data.change_in_percent < 0
      return "#{get_string(@data.change)} (#{get_string(@data.change_in_percent)} %)"
    elsif @data.change_in_percent > 0
      return "#{'+' if @data.change > 0 }#{get_string(@data.change)} (#{'+' if @data.change > 0}#{get_string(@data.change_in_percent)} %)"
    else
      return "#{'%.2f' % @data.change_in_percent.to_f}%"
    end
  end

  def get_change_color()
    if @data.change_in_percent < 0
      return "red"
    elsif @data.change_in_percent > 0
      return "green"
    else
      return nil
    end
  end


  ##################
  # Route Handlers #
  ##################

  get '/' do
    @security = find_security_with_id(params[:id])
    symbols = [@security.symbol]
    @data = get_quotes(
        YahooFinance::Client.new,
        symbols,
        # [
        #     :change,
        #     :change_in_percent,
        #     :last_trade_price,
        #     :revenue,
        #     :ebitda,
        #     :float_shares,
        #     :shares_outstanding,
        #     :market_capitalization,
        #     :short_ratio,
        #     :pe_ratio,
        #     :earnings_per_share,
        #     :volume
        # ],

        [
            :after_hours_change_real_time                ,
            :annualized_gain                             ,
            :ask                                         ,
            :ask_real_time                               ,
            :ask_size                                    ,
            :average_daily_volume                        ,
            :bid                                         ,
            :bid_real_time                               ,
            :bid_size                                    ,
            :book_value                                  ,
            :change                                      ,
            :change_and_percent_change                   ,
            :change_from_200_day_moving_average          ,
            :change_from_50_day_moving_average           ,
            :change_from_52_week_high                    ,
            :change_From_52_week_low                     ,
            :change_in_percent                           ,
            :change_percent_realtime                     ,
            :change_real_time                            ,
            :close                                       ,
            :comission                                   ,
            :day_value_change                            ,
            :day_value_change_realtime                   ,
            :days_range                                  ,
            :days_range_realtime                         ,
            :dividend_pay_date                           ,
            :dividend_per_share                          ,
            :dividend_yield                              ,
            :earnings_per_share                          ,
            :ebitda                                      ,
            :eps_estimate_current_year                   ,
            :eps_estimate_next_quarter                   ,
            :eps_estimate_next_year                      ,
            :error_indicator                             ,
            :ex_dividend_date                            ,
            :float_shares                                ,
            :high                                        ,
            :high_52_weeks                               ,
            :high_limit                                  ,
            :holdings_gain                               ,
            :holdings_gain_percent                       ,
            :holdings_gain_percent_realtime              ,
            :holdings_gain_realtime                      ,
            :holdings_value                              ,
            :holdings_value_realtime                     ,
            :last_trade_date                             ,
            :last_trade_price                            ,
            :last_trade_realtime_withtime                ,
            :last_trade_size                             ,
            :last_trade_time                             ,
            :last_trade_with_time                        ,
            :low                                         ,
            :low_52_weeks                                ,
            :low_limit                                   ,
            :market_cap_realtime                         ,
            :market_capitalization                       ,
            :more_info                                   ,
            :moving_average_200_day                      ,
            :moving_average_50_day                       ,
            :name                                        ,
            :notes                                       ,
            :one_year_target_price                       ,
            :open                                        ,
            :order_book                                  ,
            :pe_ratio                                    ,
            :pe_ratio_realtime                           ,
            :peg_ratio                                   ,
            :percent_change_from_200_day_moving_average  ,
            :percent_change_from_50_day_moving_average   ,
            :percent_change_from_52_week_high            ,
            :percent_change_from_52_week_low             ,
            :previous_close                              ,
            :price_eps_estimate_current_year             ,
            :price_eps_Estimate_next_year                ,
            :price_paid                                  ,
            :price_per_book                              ,
            :price_per_sales                             ,
            :revenue                                     ,
            :shares_outstanding                          ,
            :shares_owned                                ,
            :short_ratio                                 ,
            :stock_exchange                              ,
            :symbol                                      ,
            :ticker_trend                                ,
            :trade_date                                  ,
            :trade_links                                 ,
            :volume                                      ,
            :weeks_range_52
        ],
        :na_as_nil => true
    )

    @data[0][:ebitda_marge] = @data[0].ebitda / @data[0].revenue * 100
    @data[0][:profit] = @data[0].earnings_per_share * @data[0].shares_outstanding

    @data = get_static_quotes(symbols, @data)
    @data = get_finance_quotes(symbols, @data)

    @data = @data[0]
    @data.to_h.each {|k,v| logger.info "#{k}: #{v}"}

    @periods = {
        '1D' => 1,
        '5D' => 5,
        '1M' => 30,
        '6M' => 30 * 6,
        '1Y' => 365,
        'Max' => 0
    }

    default = @periods['1Y']
    @history = get_history(
        @security.symbol,
        @periods[params[:period]] || default
    )

    padding = 0.01
    @min = @history.values.min * (1 - padding)
    @max = @history.values.max * (1 + padding)

    # Google Chart Options
    @library_options = {
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



    slim :security
  end
end