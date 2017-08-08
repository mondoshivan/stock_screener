require 'stock_screener/security'

class SecurityFactory

  #################################################
  # Initializes a SecurityFactory object
  #
  # * *Args*    :
  #   - +array+ -> an array with hashes
  #
  def initialize(array=[])
    array.each do |hash|

      # only add, if it does not already exist
      next if !Security.first(symbol: hash["Ticker"]).nil?

      # add
      Security.create(
          exchange: hash["Exchange"],
          name: hash["Name"],
          symbol: hash["Ticker"],
          category: hash["categoryName"]
      ).save
    end
  end

  #################################################
  # Checks if a given symbol exists
  # * *Args*    :
  #   - +symbol+ -> symbol string
  #
  def exists?(symbol)
    return !Security.first(symbol: symbol).nil?
  end

  #################################################
  # Checks if a given string exists in a Security attr.
  # * *Args*    :
  #   - +string+ -> search string
  # * *Returns* :
  #   - array with Security objects
  #
  def include?(string)
    hits = []
    return hits if string.nil?
    string = string.upcase
    Security.all.each do |security|
      if security.exchange.upcase.include?(string)
        hits << security
      elsif security.name.upcase.include?(string)
        hits << security
      elsif security.symbol.upcase.include?(string)
        hits << security
      elsif security.category.upcase.include?(string)
        hits << security
      end
    end
    return hits
  end

  #################################################
  def get_with_id(id)
    return Security.first(id: id.to_i)
  end

  #################################################
  # Get the history of a security
  # * *Args*    :
  #   - +symbol+ -> the symbol of the security
  # * *Args*    :
  #   - +number_of_days+ -> how far do we look in the past
  # * *Returns* :
  #   - hash {date=>value}: {'2017-08-08' => 15.16, ...}
  #
  def get_history(symbol, number_of_days)
    data = {}
    case true
      when number_of_days > 364
        freq = '1mo'
      when number_of_days > 60
        freq = '1wk'
      when number_of_days <= 60
        freq = '1d'
    end

    url = "https://finance.yahoo.com/quote/#{symbol.strip}/history?interval=#{freq}"
    page = Nokogiri::HTML(open(url))
    page.css('table')[1].css('tbody').css('tr').each do |row|
      divs = row.css('td')
      if divs[1].css('span').text  != 'Dividend'
        time  = divs[0].css('span').text
        year  = time.split(',')[1].strip.to_i
        month = time.split(' ')[0].strip.downcase
        day   = time.split(',')[0].split(' ')[1].strip.to_i
        time  = Time.new(year, month, day)
        time_now = Time.new(Time.now.year, Time.now.month, Time.now.day)
        diff = (time_now - time) / (3600 * 24)
        break if diff > number_of_days
        value = divs[1].css('span').text.to_f
        data[time.strftime("%F")] = value if value != 0
      end
    end
    return data
  end
end