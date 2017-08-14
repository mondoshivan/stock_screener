class SecurityController < Controller

  use AssetHandler
  helpers SecurityHelpers
  helpers StockScreenerHelpers

  def interval_selected?(interval)
    return interval == params[:period] ? 'selected' : nil
  end

  get '/' do
    @security = find_security_with_id(params[:id])
    @data = get_quotes(
        YahooFinance::Client.new,
        [@security.symbol],
        [:change_in_percent, :last_trade_price, :revenue, :ebitda, :float_shares],
        :na_as_nil => true
    )
    @data[:ebitda_marge] = '%.2f' % (get_number(@data.ebitda) / get_number(@data.revenue) * 100)

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
        'chartArea' => {'width'=> '80%', 'height' => '90%'},
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