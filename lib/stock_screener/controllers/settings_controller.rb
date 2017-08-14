
class SettingsController < Controller

  use AssetHandler
  helpers SecurityHelpers
  helpers StockScreenerHelpers

  configure do
    enable :method_override
    set :data, 'data'
  end

  get '/' do
    slim :settings
  end

  delete '/reset-db' do
    DataMapper.auto_migrate!
    flash[:notice] = "Database successfully resetted"
    redirect to('/')
  end

  put '/symbols' do
    Thread.new do
      dataDir = settings.root + '/' + settings.data
      Dir.chdir(dataDir)
      market = 'gr' # us, dr (germany), fr, hk, gb, gr (grece), all
      logger.info %x{YahooTickerDownloader.py -m #{market} stocks}
      initialize_securities(YAML.load_file('stocks.yaml'))
      Dir.glob('./stocks.*').each { |file| File.delete(file)}
      Dir.chdir(settings.root)
    end
    flash[:notice] = "Adding symbols to Database"
    redirect to('/')
  end

end
