class PortfolioController < Controller

  use AssetHandler
  helpers StockScreenerHelpers

  before do
    logged_in!
  end

  get '/' do
    slim :portfolio
  end

end
