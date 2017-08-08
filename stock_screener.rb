#!/usr/bin/env ruby

############################
# Class Path - Adjustments #
############################

lib = File.expand_path("../lib", __FILE__)
$:.unshift(lib) unless $:.include?(lib)


############
# Includes #
############

require 'sinatra'
require 'slim'
require 'dm-core'
require 'dm-migrations'
require 'sass'
require 'yaml'
require 'logger'
require 'yahoo-finance'
require 'chartkick'
require 'nokogiri'


require 'stock_screener/security_factory'
require 'stock_screener/ratio_lookup'
require 'stock_screener/table_handler'


#################
# Configuration #
#################

DataMapper.setup(:default, "sqlite3://#{Dir.pwd}/development.db")

configure :production do

end
configure :development do
  require 'sinatra/reloader'

  # DataMapper.auto_migrate!
  # DataMapper.auto_upgrade!
end
configure :test do

end

config = YAML.load_file('data/stocks.yaml')
SECURITY_FACTORY = SecurityFactory.new(config)
YAHOO_FINANCE = YahooFinance::Client.new


##################
# Route Handlers #
##################


before do
  logger.info "[params] #{params.inspect}"
end

get'/styles.css' do
  scss :styles
end

get '/' do
  logger.info "[route] get /"

  hitsPerPage = params[:hits]
  @current_page = params[:page] ? params[:page].to_i : 1
  unfiltered = SECURITY_FACTORY.include?(params[:search])
  @total = unfiltered.size
  @sh = TableHandler.new(@total, hitsPerPage)
  range = @sh.range_for_page(@current_page)
  @securities = unfiltered[range]
  @indicators = @sh.indicators(@current_page)

  slim :index
end

get '/security' do
  logger.info "[route] get /security"

  @security = SECURITY_FACTORY.get_with_id(params[:id])
  fields = [
      :change_in_percent,
      :last_trade_price
  ]
  @data = YAHOO_FINANCE.quotes(
      [@security.symbol],
      fields,
      { na_as_nil: true }
  )
  @data = @data[0]

  @history = SECURITY_FACTORY.get_history(@security.symbol, 365)
  padding = 0.01
  @min = @history.values.min * (1 - padding)
  @max = @history.values.max * (1 + padding)

  logger.info @data.inspect
  logger.info @history.inspect
  logger.info @min
  logger.info @max
  slim :security
end

not_found do
  slim :not_found, :layout => :no_layout
end