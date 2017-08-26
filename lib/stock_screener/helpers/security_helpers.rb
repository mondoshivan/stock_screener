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
      )
    end
  end

  #################################################
  def get_static_quotes(symbols, data=[OpenStruct.new])
    symbols.each_with_index do |symbol, index|
      Nokogiri::HTML(open("https://finance.yahoo.com/quote/#{symbol}/key-statistics")).xpath('//table[starts-with(@class, "table-qsp-stats")]/tbody/tr').each do |row|
        name = row.xpath('td').first.xpath('span').text.strip.downcase.gsub(' ', '_').to_sym
        value = row.xpath('td').last.text.strip
        next if value.upcase == 'N/A'
        data[index][name] = get_number_from_string(value) unless data[index][name]
      end
    end

    return data
  end

  #################################################
  def get_income_statements(symbols, data=[OpenStruct.new])
    return get_finance_quotes(:income_statement, symbols, data=[OpenStruct.new])
  end

  #################################################
  def get_balance_sheets(symbols, data=[OpenStruct.new])
    return get_finance_quotes(:balance_sheet, symbols, data=[OpenStruct.new])
  end

  #################################################
  def get_cash_flows(symbols, data=[OpenStruct.new])
    return get_finance_quotes(:cash_flow, symbols, data=[OpenStruct.new])
  end

  #################################################
  def get_finance_quotes(page_type, symbols, data=[OpenStruct.new])
    symbols.each_with_index do |symbol, index|

      page = {
          :income_statement => "https://finance.yahoo.com/quote/#{symbol}/financials",
          :balance_sheet => "https://finance.yahoo.com/quote/#{symbol}/balance-sheet",
          :cash_flow => "https://finance.yahoo.com/quote/#{symbol}/cash-flow"
      }

      data[index][page_type] = Hash.new
      section = Nokogiri::HTML(open(page[page_type])).css('section[data-test="qsp-financial"]')
      return data if section.nil? || section.empty?
      section = section[0]

      # {1: '2017', 2: '2016', ...}
      date = {}
      (1..4).each do |i|
        begin
          date[i] = section.xpath('div').last.xpath('table/tbody/tr').first.xpath('td')[i].xpath('span').text
          data[index][page_type][date[i]] = {}
        rescue NoMethodError
        end
      end
      return data if date.empty?

      from = 1
      to = section.xpath('div').last.xpath('table/tbody/tr').size - 1
      (from..to).each do |i|
        tr = section.xpath('div').last.xpath('table/tbody/tr')[i]
        next if tr.xpath('td').size < 2 # at least name and one value should exist
        name = tr.xpath('td')[0].xpath('span').text.gsub(/[\s\/]/, '_').gsub('.','').downcase.to_sym # quote name
        tr.xpath('td').each_with_index do |td, i|
          next if i == 0 # this is the name
          next unless date[i] # more values than dates not excepted
          value = tr.xpath('td')[i].xpath('span').text.strip
          next if value == ''
          multiplier = 1000 # all values are shown in thousands
          number = get_number_from_string(value) * multiplier
          data[index][page_type][date[i]][name] = number
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
  def get_number_from_string(string)
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
  def get_string_from_number(number)
    return nil unless number.kind_of?(Numeric)
    multipliers = {'M' => 1000000, 'B' => 1000000000}
    case true
      when number >= multipliers['B']
        rs = number / multipliers['B']
        rs = rs % 1 != 0 ? "#{(rs).round(2)}B" : "#{rs.to_i}B"
      when number >= multipliers['M']
        rs = number / multipliers['M']
        rs = rs % 1 != 0 ? "#{(rs).round(2)}M" : "#{rs.to_i}M"
      else
        rs = number % 1 != 0 ? '%.2f' % number : "#{number.to_i}"
    end
    return rs.gsub('.', ',')
  end

  #################################################
  def get_change_color(change)
    if change < 0
      return "red"
    elsif change > 0
      return "green"
    else
      return nil
    end
  end

  #################################################
  def get_quotes(symbols, fields, **options)
    options[:na_as_nil] = true # always nil in case of 'N/A'

    @data = YahooFinance::Client.new.quotes(
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
        symbol_data[k] = get_number_from_string(v)
      end
    end

    return @data
  end

  #################################################
  def get_last_price(symbols)
    return get_quotes(symbols, [:last_trade_price])
  end

  #################################################
  def get_all_quotes(symbols)
    data = get_quotes(
        symbols,
        [
            :after_hours_change_real_time                ,
            :annualized_gain                             ,
            :ask                                         ,
            :ask_real_time                               ,
            :ask_size                                    ,
            :average_daily_volume                        ,
            :bid                                         ,
            :bid_real_time                               ,
            :bid_size                                    ,
            :book_value                                  ,
            :change                                      ,
            :change_and_percent_change                   ,
            :change_from_200_day_moving_average          ,
            :change_from_50_day_moving_average           ,
            :change_from_52_week_high                    ,
            :change_From_52_week_low                     ,
            :change_in_percent                           ,
            :change_percent_realtime                     ,
            :change_real_time                            ,
            :close                                       ,
            :comission                                   ,
            :day_value_change                            ,
            :day_value_change_realtime                   ,
            :days_range                                  ,
            :days_range_realtime                         ,
            :dividend_pay_date                           ,
            :dividend_per_share                          ,
            :dividend_yield                              ,
            :earnings_per_share                          ,
            :ebitda                                      ,
            :eps_estimate_current_year                   ,
            :eps_estimate_next_quarter                   ,
            :eps_estimate_next_year                      ,
            :error_indicator                             ,
            :ex_dividend_date                            ,
            :float_shares                                ,
            :high                                        ,
            :high_52_weeks                               ,
            :high_limit                                  ,
            :holdings_gain                               ,
            :holdings_gain_percent                       ,
            :holdings_gain_percent_realtime              ,
            :holdings_gain_realtime                      ,
            :holdings_value                              ,
            :holdings_value_realtime                     ,
            :last_trade_date                             ,
            :last_trade_price                            ,
            :last_trade_realtime_withtime                ,
            :last_trade_size                             ,
            :last_trade_time                             ,
            :last_trade_with_time                        ,
            :low                                         ,
            :low_52_weeks                                ,
            :low_limit                                   ,
            :market_cap_realtime                         ,
            :market_capitalization                       ,
            :more_info                                   ,
            :moving_average_200_day                      ,
            :moving_average_50_day                       ,
            :name                                        ,
            :notes                                       ,
            :one_year_target_price                       ,
            :open                                        ,
            :order_book                                  ,
            :pe_ratio                                    ,
            :pe_ratio_realtime                           ,
            :peg_ratio                                   ,
            :percent_change_from_200_day_moving_average  ,
            :percent_change_from_50_day_moving_average   ,
            :percent_change_from_52_week_high            ,
            :percent_change_from_52_week_low             ,
            :previous_close                              ,
            :price_eps_estimate_current_year             ,
            :price_eps_Estimate_next_year                ,
            :price_paid                                  ,
            :price_per_book                              ,
            :price_per_sales                             ,
            :revenue                                     ,
            :shares_outstanding                          ,
            :shares_owned                                ,
            :short_ratio                                 ,
            :stock_exchange                              ,
            :symbol                                      ,
            :ticker_trend                                ,
            :trade_date                                  ,
            :trade_links                                 ,
            :volume                                      ,
            :weeks_range_52
        ]
    )

    data.each do |item|
      if item.ebitda && item.revenue
        item[:ebitda_marge] = item.ebitda / item.revenue * 100
      end

      if item.earnings_per_share && item.shares_outstanding
        item[:profit] = item.earnings_per_share * item.shares_outstanding
      end
    end

    # data = get_static_quotes(symbols, data)
    # data = get_finance_quotes(symbols, data)

    return data
  end

end