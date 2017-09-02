require 'dm-core'
require 'dm-migrations'

class Ticker

  include DataMapper::Resource

  property :id, Serial
  property :name, String

end



