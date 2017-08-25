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
  #   - +string+ -> max hits (0 = all)
  # * *Returns* :
  #   - array with Security objects
  #
  def security_includes?(string, **options)
    return [] if string.nil?
    string = string.upcase
    options[:max] = options[:max].nil? ? 0 : options[:max]
    options[:filter][:category] = 'all' if options[:filter][:category].nil?
    options[:filter][:exchange] = 'all' if options[:filter][:exchange].nil?
    options[:filter].delete(:category) if options[:filter][:category].downcase == 'all'
    options[:filter].delete(:exchange) if options[:filter][:exchange].downcase == 'all'

    hits = []
    Security.all(options[:filter]).each do |security|
      if security.exchange.name.upcase.include?(string)
        hits << security
      elsif security.name.upcase.include?(string)
        hits << security
      elsif security.symbol.upcase.include?(string)
        hits << security
      elsif security.category.name.upcase.include?(string)
        hits << security
      end
      break if options[:max] > 0 && options[:max] == hits.count
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

      # add
      sec = Security.create(
          exchange: Exchange.first_or_create(name: hash["Exchange"]),
          category: Category.first_or_create(name: hash["categoryName"]),
          name: hash["Name"],
          symbol: hash["Ticker"]
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

    @data.each do |symbol_data|
      symbol_data.to_h.each do |k,v|
        if v.nil?
          symbol_data.delete_field(k)
          next
        end
        symbol_data[k] = get_number(v)
      end
    end

    return @data
  end

  #################################################
  def get_static_quotes(symbols, data=[OpenStruct.new])
    symbols.each_with_index do |symbol, index|
      Nokogiri::HTML(open("https://finance.yahoo.com/quote/#{symbol}/key-statistics")).xpath('//table[starts-with(@class, "table-qsp-stats")]/tbody/tr').each do |row|
        name = row.xpath('td').first.xpath('span').text.strip.downcase.gsub(' ', '_').to_sym
        value = row.xpath('td').last.text.strip
        next if value.upcase == 'N/A'
        data[index][name] = get_number(value) unless data[index][name]
      end
    end

    return data
  end

  #################################################
  def get_finance_quotes(symbols, data=[OpenStruct.new])
    symbols.each_with_index do |symbol, index|
      data[index].financial = Hash.new

      page = {
          :income_statement => "https://finance.yahoo.com/quote/#{symbol}/financials",
          :balance_sheet => "https://finance.yahoo.com/quote/#{symbol}/balance-sheet",
          :cash_flow => "https://finance.yahoo.com/quote/#{symbol}/cash-flow"
      }

      page.each do |page_type, url|
        Nokogiri::HTML(open(url)).css('section[data-test="qsp-financial"]').each do |section|
          data[index].financial[page_type] = Hash.new

          date = {}
          (1..4).each {|i| date[i] = section.xpath('div').last.xpath('table/tbody/tr').first.xpath('td')[i].xpath('span').text }

          from = 1
          to = section.xpath('div').last.xpath('table/tbody/tr').size - 1
          (from..to).each do |i|
            tr = section.xpath('div').last.xpath('table/tbody/tr')[i]
            next if tr.xpath('td').size < 2 # at least name and one value should exist
            name = tr.xpath('td')[0].xpath('span').text # quote name
            data[index].financial[page_type][name] = Hash.new
            tr.xpath('td').each_with_index do |td, i|
              next if i == 0 # this is the name
              next unless date[i] # more values than dates not excepted
              value = tr.xpath('td')[i].xpath('span').text.strip
              next if value == ''
              data[index].financial[page_type][name][date[i]] = get_number(value)
            end
          end
        end
      end
    end

    return data
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
  # Searches for postfix char on last
  # position in a string and replaces the char with
  # its corresponding number.
  #
  # * *Args*    :
  #   - +string+ ->
  # * *Returns* :
  #   - float
  #
  def get_number(string)
    raise TypeError, "Illegal type: #{string.class}" unless string.kind_of?(String)
    string = string.strip.gsub(',', '')
    return string.to_f if string !~ /^\d+\.?\d+[mb]$/i
    char = string[-1].upcase
    number = string[0..-2].to_f
    multipliers = {'M' => 1000000, 'B' => 1000000000}
    rs = number * multipliers[char]
    return rs
  end

  #################################################
  # Transforms a number into a string. Big numbers
  # are shorted and added with a postfix char
  #
  # * *Args*    :
  #   - +number+ ->
  # * *Returns* :
  #   - string
  #
  def get_string(number)
    return nil unless number.kind_of?(Numeric)
    multipliers = {'M' => 1000000, 'B' => 1000000000}
    case true
      when number >= multipliers['B']
        rs = number / multipliers['B']
        return rs % 1 != 0 ? "#{(rs).round(2)}B" : "#{rs.to_i}B"
      when number >= multipliers['M']
        rs = number / multipliers['M']
        return rs % 1 != 0 ? "#{(rs).round(2)}M" : "#{rs.to_i}M"
      else
        return number % 1 != 0 ? '%.2f' % number : "#{number.to_i}"
    end
  end

  def get_change_color(change)
    if change < 0
      return "red"
    elsif change > 0
      return "green"
    else
      return nil
    end
  end

end