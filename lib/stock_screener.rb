#!/usr/bin/env ruby


############
# Includes #
############

require 'sinatra/base'
require 'sinatra/reloader'
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

require 'stock_screener/helpers/stock_screener_helpers'
require 'stock_screener/security_factory'
require 'stock_screener/ratio_lookup'
require 'stock_screener/table_handler'
require 'stock_screener/asset_handler'
require 'stock_screener/helpers/security_helpers'
require 'stock_screener/controllers/security_controller'
require 'stock_screener/models/security'

SECURITY_FACTORY = SecurityFactory.new()
YAHOO_FINANCE = YahooFinance::Client.new

class StockScreener < Sinatra::Base

  use AssetHandler
  helpers SecurityHelpers
  helpers StockScreenerHelpers

  #################
  # Configuration #
  #################

  configure :production do
    DataMapper.setup(:default, "sqlite3://#{Dir.pwd}/development.db")
  end
  configure :development do
    register Sinatra::Reloader
    enable :reloader

    set :root, File.join(File.dirname(__FILE__), '..')

    DataMapper.setup(:default, "sqlite3://#{Dir.pwd}/development.db")
    # DataMapper.auto_migrate!
    # DataMapper.auto_upgrade!

    # config = YAML.load_file('data/stocks.yaml')
    # initialize_securities(config)
  end
  configure :test do

  end


  ###########
  # Helpers #
  ###########

  def table_page_selected?(page)
    return page == @current_page ? 'selected' : nil
  end


  ##################
  # Route Handlers #
  ##################


  before do
    logger.info "[params] #{params.inspect}"
  end

  get '/' do
    logger.info "[route] get /"

    hitsPerPage = params[:hits]
    @current_page = params[:page] ? params[:page].to_i : 1
    unfiltered = security_includes?(params[:search])
    @total = unfiltered.size
    @th = TableHandler.new(@total, hitsPerPage)
    range = @th.range_for_page(@current_page)
    @securities = unfiltered[range]
    @indicators = @th.indicators(@current_page)

    slim :index
  end

  get '/portfolio' do
    slim :portfolio
  end

  not_found do
    slim :not_found, :layout => :no_layout
  end

end
