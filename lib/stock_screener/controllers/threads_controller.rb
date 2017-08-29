BACKGROUND_TASKS = []

class ThreadsController < Controller

  use AssetHandler
  helpers StockScreenerHelpers

  ###########
  # Helpers #
  ###########

  def get_living_threads()
    living = []
    BACKGROUND_TASKS.each do |thread|
      living << thread if thread.alive?
    end
    return living
  end

  def get_thread_info()
    rs = []
    get_living_threads().each do |thread|
      hash = {}
      thread.thread_variables.each do |name|
        hash[name] = thread.thread_variable_get(name)
      end
      rs << hash
    end
    return rs
  end


  ##################
  # Route Handlers #
  ##################

  before do
    protected!
  end

  get '/' do
    slim :threads
  end

  get '/running' do
    content_type :json

    return get_thread_info().to_json
  end

end