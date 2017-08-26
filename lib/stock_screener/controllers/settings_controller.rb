
class SettingsController < Controller

  use AssetHandler
  helpers SearchHelpers
  helpers SecurityHelpers
  helpers StockScreenerHelpers

  configure do
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

  before do
    protected!
  end

  get '/' do
    slim :settings
  end

  delete '/reset-db' do
    halt 403, slim(:unauthorized) unless settings.development?
    DataMapper.auto_migrate!
    flash[:notice] = "Database successfully resetted"
    redirect to('/')
  end

  get '/symbols' do
    Thread.new do
      FileUtils.mkdir_p(settings.data_dir)
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
      pwd = Dir.pwd
      file = 'stocks.yaml'
      yaml = YAML.load_file(file)
      Dir.chdir(settings.root)
      initialize_securities(yaml)
    end
    flash[:notice] = "Adding Symbols to Database in Background"
    redirect to('/')
  end

  put '/scan' do
    exchange = Exchange.first(id: params[:exchange_id])

    # error condition
    halt 404, slim(:not_found) unless exchange

    Security.all(exchange: exchange).each do |security|
      logger.info "Handling: #{security.symbol}"
      symbols = [security.symbol]
      data = get_income_statements(symbols)
      data[0][:income_statement].each do |date, numbers|
        # ToDo: Check if IncomeStatement already exists!
        income_statement = IncomeStatement.new(numbers)
        income_statement.date = Date.strptime(date, '%m/%d/%Y')
        income_statement.period = IncomeStatement::PERIOD[:yearly]
        security.income_statements << income_statement
        security.save
        income_statement.save
      end
      break
    end
    flash[:notice] = "Scan is running in background"
    redirect to('/')
  end

end
