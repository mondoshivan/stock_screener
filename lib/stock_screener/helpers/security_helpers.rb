module SecurityHelpers

  #################################################
  # Checks if a given symbol exists.
  # * *Args*    :
  #   - +symbol+ -> symbol string
  #
  def security_exists?(symbol)
    return !Security.first(symbol: symbol).nil?
  end

  #################################################
  # Checks if a given string exists in a Security attribute.
  # * *Args*    :
  #   - +string+ -> search string
  # * *Returns* :
  #   - array with Security objects
  #
  def security_includes?(string)
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
  def find_security_with_id(id)
    return Security.first(id: id.to_i)
  end

  #################################################
  # Initializes a SecurityFactory object.
  #
  # * *Args*    :
  #   - +array+ -> an array with hashes
  #
  def initialize_securities(array=[])
    array.each do |hash|

      # only add, if it does not already exist
      next if !Security.first(symbol: hash["Ticker"]).nil?

      # insert category
      category = Category.first_or_create(name: hash["categoryName"])

      # add
      Security.create(
          exchange: hash["Exchange"],
          name: hash["Name"],
          symbol: hash["Ticker"],
          category: category.id
      ).save
    end
  end

  #################################################
  def get_quotes(api, symbols, fields, **options)
    @data = api.quotes(
        symbols,
        fields,
        options
    )
    return @data[0]
  end

  #################################################
  # Get the history of a security.
  # * *Args*    :
  #   - +symbol+ -> the symbol of the security
  #   - +number_of_days+ -> how far do we look in the past (0 = forever)
  # * *Returns* :
  #   - hash {date=>value}: {'2017-08-08' => 15.16, ...}
  #
  def get_history(symbol, number_of_days)
    data = {}
    case true
      when number_of_days == 0
        interval = '1mo'
      when number_of_days > 547
        interval = '1mo'
      when number_of_days > 120
        interval = '1wk'
      when number_of_days <= 120
        interval = '1d'
      else
        raise ArgumentError, "illegal value: #{number_of_days.inspect}"
    end

    start = number_of_days == 0 ? Time.new(1980).to_i : Time.now().to_i - number_of_days * 24 * 60 * 60
    stop = Time.now.to_i
    url = "https://finance.yahoo.com/quote/#{symbol.strip}/history?interval=#{interval}&period1=#{start}&period2=#{stop}"
    page = Nokogiri::HTML(open(url))
    page.css('table')[1].css('tbody').css('tr').each do |row|
      divs = row.css('td')
      if divs[1].css('span').text  != 'Dividend'
        time  = divs[0].css('span').text
        year  = time.split(',')[1].strip.to_i
        month = time.split(' ')[0].strip.downcase
        day   = time.split(',')[0].split(' ')[1].strip.to_i
        time  = Time.new(year, month, day)
        if number_of_days != 0
          time_now = Time.new(Time.now.year, Time.now.month, Time.now.day)
          diff = (time_now - time) / (3600 * 24)
          break if diff > number_of_days
        end
        value = divs[1].css('span').text.to_f
        data[time.strftime("%F")] = value if value != 0
      end
    end
    return data
  end

  #################################################
  def get_number(string)
    string.strip!
    return string.to_f if string !~ /^\d+\.?\d+[mb]$/i
    char = string[-1].upcase
    number = string[0..-2].to_f
    multipliers = {'M' => 1000000, 'B' => 1000000000}
    rs = number * multipliers[char]
    return rs
  end

end