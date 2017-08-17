require 'dm-core'
require 'dm-migrations'

class Security

  include DataMapper::Resource

  property :id, Serial
  property :exchange, String
  property :name, String
  property :symbol, String
  property :category, String

  # property :revenue, Integer
  # property :gross_profit, Integer
  # property :ebitda, Integer
  # property :ebit, Integer
  # property :ebt, Integer
  # property :net_profit, Integer
  #
  # property :equity, Integer
  # property :dept, Integer

end

DataMapper.finalize


