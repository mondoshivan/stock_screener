require 'stock_screener/security'

class SymbolManager

  attr_reader :securities

  #################################################
  # Initializes a SymbolManager object
  #
  def initialize(array=[])
    @securities = []

    array.each do |hash|
      addSecurity(
          Security.new(
              hash[:Exchange],
              hash[:Name],
              hash[:Ticker],
              hash[:categoryName]
          )
      )
    end
  end

  #################################################
  # Checks if a given symbol exists
  # * *Args*    :
  #   - +symbol+ -> symbol string
  #
  def exists?(symbol)
    @securities.each do |security|
      return true if symbol == security.symbol
    end
    return false
  end

  #################################################
  # Adds a sequrity to the @sequrities array
  # * *Args*    :
  #   - +sequrity+ -> Sequrity object
  # * *Returns* :
  #   - the added Security object
  #
  def addSecurity(sequrity)
    @securities << sequrity
    return sequrity
  end

end