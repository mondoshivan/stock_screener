

class Security

  attr_reader :exchange
  attr_reader :name
  attr_reader :symbol
  attr_reader :category

  #################################################
  # Initializes a Security object
  # * *Args*    :
  #   - +exchange+ -> name of the stock exchange where the security is traded
  #   - +name+ -> name of the security
  #   - +symbol+ -> symbol of the security
  #   - +category+ -> category the security belongs to
  #
  def initialize(exchange=nil, name=nil, symbol=nil, category=nil)
    @exchange = exchange
    @name = name
    @symbol = symbol
    @category = category
  end

end