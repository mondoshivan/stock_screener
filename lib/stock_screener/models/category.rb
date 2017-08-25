require 'dm-core'
require 'dm-migrations'

class Category

  include DataMapper::Resource

  property :id, Serial
  property :name, String

end



