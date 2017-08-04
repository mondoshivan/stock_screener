

class TableHandler

  attr_reader :total
  attr_reader :hits_per_page
  attr_reader :last_page
  attr_reader :max_indicators

  ##########################################
  def initialize(total, hits_per_page=10, max_indicators=5)
    total = total.to_i
    hits_per_page = hits_per_page.to_i
    max_indicators = max_indicators.to_i

    total = 0 if total.nil? || total < 0
    hits_per_page = 10 if hits_per_page.nil? || hits_per_page < 10
    max_indicators = 4 if max_indicators < 4

    @total = total
    @hits_per_page = hits_per_page
    @last_page = (total == 0 ? total : total - 1) / hits_per_page + 1
    @max_indicators = max_indicators
  end

  ##########################################
  def range_for_page(page)
    page = page.to_i
    page = @last_page if page > @last_page
    page = 1 if page < 1

    s = page * @hits_per_page - @hits_per_page
    e = s + @hits_per_page - 1
    return (s..e)
  end

  ##########################################
  def indicators(current_page)
    current_page = current_page.to_i
    current_page = 1 if current_page < 1
    current_page = @last_page if current_page > @last_page

    rs = {}

    # only 1 page
    return rs if @last_page == 1

    if @last_page <= @max_indicators
      # 2 to maxIndicator pages (all digits visible)
      (1..@last_page).each do |i|
        rs[i] = i
      end

    else
      # More than available indicator pages
      if current_page <= @max_indicators / 2 + @max_indicators % 2
        (1..@max_indicators - 1).each do |i|
          rs[i] = i
        end
        rs['>'] = current_page + 1
      elsif current_page >= @last_page - @max_indicators / 2
        rs['<'] = current_page - 1
        ((@last_page - @max_indicators + 2)..@last_page).each do |i|
          rs[i] = i
        end
      elsif current_page > @max_indicators / 2 && current_page < @last_page - @max_indicators / 2
        rs['<'] = current_page - 1
        ((current_page - 1)..(current_page + 1)).each do |i|
          rs[i] = i
        end
        rs['>'] = current_page + 1
      end

    end

    return rs
  end

end