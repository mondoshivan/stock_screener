
class SearchController < Controller

  use AssetHandler
  helpers SearchHelpers
  helpers SecurityHelpers
  helpers StockScreenerHelpers

  configure do
    enable :method_override

    set :hits, ['10','20','50','100']
  end


  ###########
  # Helpers #
  ###########

  def table_page_selected?(page)
    return page == @current_page ? 'selected' : nil
  end

  def category_selected?(category)
    return category.id == params[:category].to_i ? 'selected' : nil
  end

  def exchange_selected?(exchange)
    return exchange.id == params[:exchange].to_i ? 'selected' : nil
  end

  def page_indicator_href(page)
    hash = request.env['rack.request.query_hash']
    hash['page'] = page
    uri = search_uri(hash)
    return uri
  end

  def hits_selected?(hits)
    return hits == params[:hits] ? 'selected' : nil
  end

  ##################
  # Route Handlers #
  ##################

  get '/' do
    @exchanges = Exchange.all
    @categories = Category.all

    hitsPerPage = params[:hits]
    @current_page = params[:page] ? params[:page].to_i : 1
    unfiltered = security_includes?(params[:search], :filter => {
        :exchange => params[:exchange],
        :category => params[:category]
    })
    @total = unfiltered.size
    @th = TableHandler.new(@total, hitsPerPage)
    range = @th.range_for_page(@current_page)
    @securities = unfiltered[range]
    @indicators = @th.indicators(@current_page)

    slim :search
  end

  get '/tickers' do
    content_type :json

    tickers = []
    Ticker.all(
        :name.like => "%#{params[:input]}%",
        :fields => [:name],
        :order => [ :name.asc ]
    ).each { |ticker| tickers << ticker.name }

    return tickers.to_json
  end

end
