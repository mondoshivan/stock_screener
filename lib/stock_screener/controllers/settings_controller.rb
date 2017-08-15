
class SettingsController < Controller

  use AssetHandler
  helpers SearchHelpers
  helpers SecurityHelpers
  helpers StockScreenerHelpers

  configure do
    enable :method_override
    set :data_dir, settings.root + '/data'
    set :country, {
        :all => 'All',
        :us => 'United States',
        :dr => 'Germany',
        :fr => 'France',
        :hk => 'Hong Kong',
        :gb => 'Great Britain',
        :gr => 'Greece'
    }
  end

  get '/' do
    slim :settings
  end

  delete '/reset-db' do
    DataMapper.auto_migrate!
    flash[:notice] = "Database successfully resetted"
    redirect to('/')
  end

  get '/symbols' do
    Thread.new do
      Dir.chdir(settings.data_dir)
      Dir.glob('./stocks.*').each { |file| File.delete(file)}
      logger.info %x{YahooTickerDownloader.py -m #{params[:country]} stocks}
      Dir.chdir(settings.root)
    end
    flash[:notice] = "Downloading Symbols in Background"
    redirect to('/')
  end

  put '/init-symbols' do
    Thread.new do
      Dir.chdir(settings.data_dir)
      file = 'stocks.yaml'
      initialize_securities(YAML.load_file(file))
      Dir.chdir(settings.root)
    end
    flash[:notice] = "Adding Symbols to Database in Background"
    redirect to('/')
  end

end
