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

require 'stock_screener/security_factory'
require 'stock_screener/ratio_lookup'
require 'stock_screener/search_handler'


#################
# Configuration #
#################

configure :production do

end
configure :development do
  require 'sinatra/reloader'
  DataMapper.setup(:default, "sqlite3://#{Dir.pwd}/development.db")
  # DataMapper.auto_migrate!
  DataMapper.auto_upgrade!
end
configure :test do

end

config = YAML.load_file('data/stocks_short.yaml')
SECURITY_FACTORY = SecurityFactory.new(config)


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
  @page = params[:page] ? params[:page] : 1
  unfiltered = SECURITY_FACTORY.include?(params[:search])
  @total = unfiltered.size
  @sh = SearchHandler.new(@total, hitsPerPage)
  range = @sh.rangeForPage(@page)
  @securities = unfiltered[range]
  @indicators = SearchHandler.indicators

  slim :index
end

not_found do
  slim :not_found, :layout => :no_layout
end