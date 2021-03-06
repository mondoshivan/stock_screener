require 'dm-core'
require 'dm-migrations'

class Security

  include DataMapper::Resource

  property :id, Serial
  property :name, String

  belongs_to :ticker
  belongs_to :category
  belongs_to :exchange

  has n, :income_statements
  has n, :balance_sheets

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




