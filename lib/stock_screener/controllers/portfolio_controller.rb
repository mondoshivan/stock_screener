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
      tickers = [item.security.ticker.name]
      @data = get_last_price(tickers)
      @data = @data[0]
      change = @data.last_trade_price - item.price
      change_in_percent = change / item.price * 100
      total_change = change * item.volume
      total_current_value = item.volume * @data.last_trade_price
      total_purchase_value = item.volume * item.price
      @changes[item.security.id] = {
          :last_trade_price => @data.last_trade_price,
          :change => change,
          :change_in_percent => change_in_percent,
          :total_change => total_change,
          :total_current_value => total_current_value,
          :total_purchase_value => total_purchase_value,
          :color => get_change_color(change)
      }
    end

    slim :portfolio
  end

end
