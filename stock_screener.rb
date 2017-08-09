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
require 'coffee-script'
require 'therubyracer'


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

  # config = YAML.load_file('data/stocks.yaml')
  # initialize_securities(config)
end
configure :test do

end


SECURITY_FACTORY = SecurityFactory.new()
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

get('/application.js') do
  coffee :application
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

get '/security' do
  logger.info "[route] get /security"

  @security = find_security_with_id(params[:id])
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

  @periods = {
      '1D' => 1,
      '5D' => 5,
      '1M' => 30,
      '6M' => 30 * 6,
      '1Y' => 365,
      'Max' => 0
  }

  default = @periods['1Y']
  @history = SECURITY_FACTORY.get_history(
      @security.symbol,
      @periods[params[:period]] || default
  )

  padding = 0.01
  @min = @history.values.min * (1 - padding)
  @max = @history.values.max * (1 + padding)
  @options = {
      'curveType' => 'none', # none or function
      'enableInteractivity' => true, # true, false
      'explorer' => nil, # { 'actions' => ['dragToZoom', 'rightClickToReset'] }, # nil, {}
      'pointSize' => 0,
      'pointsVisible' => false,
      'trendlines' => {
          0 => {
              'type' => 'polynomial', #  linear, polynomial, and exponential.
              'color' => 'green',
              'lineWidth' => 3,
              'opacity' => 0.3,
              'showR2' => true,
              'visibleInLegend' => true,
              'pointsVisible' => false,
              'enableInteractivity' => false
          }
      },
      'vAxis' => {
          'gridlines' => {
              'color' => '#333',
              'count' => 8
          }
      }
  }

  logger.info @data.inspect
  logger.info @history.inspect
  logger.info @min
  logger.info @max
  slim :security
end

get '/portfolio' do
  slim :portfolio
end

not_found do
  slim :not_found, :layout => :no_layout
end

helpers do
  def interval_selected?(interval)
    return interval == params[:period] ? 'selected' : nil
  end

  def table_page_selected?(page)
    return page == @current_page ? 'selected' : nil
  end

  def nav_page_selected?(path='/')
    (request.path==path || request.path==path+'/') ? 'selected' : nil
  end
end