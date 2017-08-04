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
  def getWithId(id)
    return Security.first(id: id.to_i)
  end
end