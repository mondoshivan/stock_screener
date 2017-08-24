require 'dm-core'
require 'dm-migrations'

class User

  include DataMapper::Resource

  property :id, Serial
  property :name, String
  property :password, String
  property :admin, Boolean, :default  => false

end

DataMapper.finalize


