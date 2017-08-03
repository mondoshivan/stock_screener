

class SearchHandler

  attr_reader :total
  attr_reader :hitsPerPage
  attr_reader :lastPage
  attr_reader :maxIndicators

  ##########################################
  def initialize(total, hitsPerPage=10, maxIndicators=5)
    total = total.to_i
    hitsPerPage = hitsPerPage.to_i
    maxIndicators = maxIndicators.to_i

    total = 0 if total.nil? || total < 0
    hitsPerPage = 10 if hitsPerPage.nil? || hitsPerPage < 10
    maxIndicators = 4 if maxIndicators < 4

    @total = total
    @hitsPerPage = hitsPerPage
    @lastPage = (total == 0 ? total : total - 1) / hitsPerPage + 1
    @maxIndicators = maxIndicators
  end

  ##########################################
  def rangeForPage(page)
    page = page.to_i
    page = @lastPage if page > @lastPage
    page = 1 if page < 1

    s = page * @hitsPerPage - @hitsPerPage
    e = s + @hitsPerPage - 1
    return (s..e)
  end

  ##########################################
  def indicators(currentPage)
    currentPage = currentPage.to_i
    currentPage = 1 if currentPage < 1
    currentPage = @lastPage if currentPage > @lastPage

    rs = {}
    return rs if @lastPage == 1

    if @lastPage > @maxIndicators
      s = currentPage - (@maxIndicators / 2)
      s = 1 if s < 1

      e = s + @maxIndicators - 1
      if e > lastPage
        e = @lastPage
        s = e - @maxIndicators
      end

      (s..e).each do |i|
        rs[i] = i
      end

      rs[e] = '>' if s == 1

    else
      (1..@lastPage).each do |i|
        rs[i] = i
      end
    end

    return rs
  end

end