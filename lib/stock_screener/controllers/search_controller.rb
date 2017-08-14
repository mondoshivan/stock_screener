
class SearchController < Controller

  use AssetHandler
  helpers SecurityHelpers
  helpers StockScreenerHelpers

  configure do
    enable :method_override
  end


  ###########
  # Helpers #
  ###########

  def table_page_selected?(page)
    return page == @current_page ? 'selected' : nil
  end


  ##################
  # Route Handlers #
  ##################

  get '/' do
    @categories = Category.all

    hitsPerPage = params[:hits]
    @current_page = params[:page] ? params[:page].to_i : 1
    unfiltered = security_includes?(params[:search])
    @total = unfiltered.size
    @th = TableHandler.new(@total, hitsPerPage)
    range = @th.range_for_page(@current_page)
    @securities = unfiltered[range]
    @indicators = @th.indicators(@current_page)

    slim :search
  end


end
