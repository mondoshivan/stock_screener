#!/usr/bin/env ruby


############
# Includes #
############

require 'sinatra/base'
require 'sinatra/reloader'
require 'sinatra/flash'
require 'slim'
require 'dm-core'
require 'dm-migrations'
require 'sass'
require 'yaml'
require 'logger'
require 'yahoo-finance'
require 'chartkick'
require 'nokogiri'
require 'coffee-script'
require 'therubyracer'
require 'uri'
require 'fileutils'
require 'bcrypt'

require 'stock_screener/table_handler'

# Helpers
require 'stock_screener/helpers/stock_screener_helpers'
require 'stock_screener/helpers/security_helpers'
require 'stock_screener/helpers/search_helpers'
require 'stock_screener/helpers/auth_helpers'

# Controllers
require 'stock_screener/controllers/controller'
require 'stock_screener/controllers/asset_handler'
require 'stock_screener/controllers/security_controller'
require 'stock_screener/controllers/settings_controller'
require 'stock_screener/controllers/search_controller'
require 'stock_screener/controllers/portfolio_controller'
require 'stock_screener/controllers/users_controller'

# Models
require 'stock_screener/models/security'
require 'stock_screener/models/category'
require 'stock_screener/models/exchange'
require 'stock_screener/models/user'
require 'stock_screener/models/portfolio_items'

YAHOO_FINANCE = YahooFinance::Client.new

class StockScreener < Controller

  use AssetHandler
  helpers SearchHelpers
  helpers SecurityHelpers
  helpers StockScreenerHelpers


  #################
  # Configuration #
  #################

  configure :production do
    DataMapper.setup(:default, "sqlite3://#{Dir.pwd}/development.db")
  end
  configure :development do
    set :root, File.join(File.dirname(__FILE__), '..')

    DataMapper.setup(:default, "sqlite3://#{Dir.pwd}/development.db")
    DataMapper.auto_upgrade!
  end
  configure :test do

  end


  ##################
  # Route Handlers #
  ##################

  get '/' do
    slim :index
  end

  get '/login' do
    slim :login
  end

  get '/register' do
    slim :register
  end

  post '/register' do
    if params['username'].empty? || params['password'].empty?
      flash[:notice] = "Registration failed!"
      redirect to('/register')
    else
      User.create(
          name: params["username"],
          password: params["password"],
          admin: (params["admin"] == 'admin')
      ).save
      flash[:notice] = "New user registered!"
      redirect to('/login')
    end
  end

  not_found do
    slim :not_found, :layout => :no_layout
  end

  # directly executed (then we need to call 'run') or by another file?
  run! if __FILE__ == $0

end
