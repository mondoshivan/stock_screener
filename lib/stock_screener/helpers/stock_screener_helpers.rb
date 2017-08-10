module StockScreenerHelpers
  def nav_page_selected?(path='/')
    (request.path==path || request.path==path+'/') ? 'selected' : nil
  end
end