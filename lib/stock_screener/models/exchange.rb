require 'dm-core'
require 'dm-migrations'

class Exchange

  include DataMapper::Resource

  property :id, Serial
  property :name, String

end

DataMapper.finalize
