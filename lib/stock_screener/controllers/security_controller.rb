class SecurityController < Sinatra::Base

  helpers SecurityHelpers
  helpers StockScreenerHelpers

  configure do
    set :root, File.join(File.dirname(__FILE__), '../../../')
  end

  def interval_selected?(interval)
    return interval == params[:period] ? 'selected' : nil
  end

  get '/' do
    logger.info "[route] get /security"

    @security = find_security_with_id(params[:id])
    fields = [
        :change_in_percent,
        :last_trade_price
    ]
    @data = YAHOO_FINANCE.quotes(
        [@security.symbol],
        fields,
        { na_as_nil: true }
    )
    @data = @data[0]

    @periods = {
        '1D' => 1,
        '5D' => 5,
        '1M' => 30,
        '6M' => 30 * 6,
        '1Y' => 365,
        'Max' => 0
    }

    default = @periods['1Y']
    @history = SECURITY_FACTORY.get_history(
        @security.symbol,
        @periods[params[:period]] || default
    )

    padding = 0.01
    @min = @history.values.min * (1 - padding)
    @max = @history.values.max * (1 + padding)
    @options = {
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

    logger.info @data.inspect
    logger.info @history.inspect
    logger.info @min
    logger.info @max
    slim :security
  end
end