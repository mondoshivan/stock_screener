class PortfolioController < Controller

  use AssetHandler
  helpers StockScreenerHelpers
  helpers SecurityHelpers
  helpers UsersHelpers

  before do
    logged_in!
  end

  get '/' do
    options = {:user => get_user_with_id(session[:user_id])}
    @portfolio = Item.all(options)
    @changes = {}
    @portfolio.each do |item|
      @data = get_quotes(
          YahooFinance::Client.new,
          [item.security.symbol],
          [:last_trade_price],
          :na_as_nil => true
      )
      @data = @data[0]
      change = @data.last_trade_price - item.price
      change_in_percent = change / item.price * 100
      total = change * item.volume
      @changes[item.security.id] = [change, change_in_percent, total]
    end

    slim :portfolio
  end

end
