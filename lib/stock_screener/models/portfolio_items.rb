
class Item

  include DataMapper::Resource

  property :id, Serial
  property :volume, Integer
  property :price, Float
  property :signed_at, DateTime

  belongs_to :user
  belongs_to :security
end