class IndexController < Controller

  use AssetHandler
  helpers StockScreenerHelpers

  #################
  # Configuration #
  #################

  configure do


  end


  ###########
  # Helpers #
  ###########

  def find_index_with_id(id)
    return id.nil? ? nil : Index.first(id: id.to_i)
  end

  def all_indexes()
    return Index.all()
  end


  ##################
  # Route Handlers #
  ##################

  get '/' do
    @indexes = all_indexes()
    slim :index
  end

  get '/:index_id' do
    @index = find_index_with_id(params[:index_id])
    slim :index
  end


end