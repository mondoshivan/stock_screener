module StockScreenerHelpers
  def nav_page_selected?(path='/')
    return request.path == path || request.path == path + '/' ? 'selected' : nil
  end
end