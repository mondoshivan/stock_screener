require 'dm-core'
require 'dm-migrations'

class Security

  include DataMapper::Resource

  property :id, Serial
  property :exchange, String
  property :name, String
  property :symbol, String
  property :category, String

end

DataMapper.finalize


