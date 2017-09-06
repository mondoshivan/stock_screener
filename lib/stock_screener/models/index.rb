require 'dm-core'
require 'dm-migrations'

class Index

  include DataMapper::Resource

  property :id, Serial
  property :name, String

  belongs_to :ticker
  belongs_to :exchange

end




