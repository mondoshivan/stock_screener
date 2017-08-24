# Configuration files used by Rack apps

############################
# Class Path - Adjustments #
############################

lib = File.expand_path("../lib", __FILE__)
$:.unshift(lib) unless $:.include?(lib)


############
# Includes #
############

require 'sinatra/base'
require 'stock_screener'

map('/search') { run SearchController }
map('/settings') { run SettingsController }
map('/security') { run SecurityController }
map('/portfolio') { run PortfolioController }
map('/users') { run UsersController }
map('/') { run StockScreener }