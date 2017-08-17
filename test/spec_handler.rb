
lib = File.expand_path("../../test", __FILE__)
$:.unshift(lib) unless $:.include?(lib)

require 'dm-core'
require 'dm-migrations'

DataMapper.setup(:default, "sqlite3://#{Dir.pwd}/test.db")
DataMapper.auto_migrate!
DataMapper.auto_upgrade!

require 'stock_screener/table_handler_spec'
require 'stock_screener/helpers/security_helpers_spec'