#!/usr/bin/env ruby

lib = File.expand_path("../lib", __FILE__)
$:.unshift(lib) unless $:.include?(lib)

require 'sinatra'
require 'slim'

require 'stock_screener/symbol_manager'
require 'stock_screener/ratio_lookup'


get '/' do
  logger.info "loading data"
  slim :index
end

get '/:symbol' do
  logger.info "loading data"

  config = [
      {
          :Exchange => "FRA",
          :Name => 'Volkswagen Aktiengesellschaft',
          :Ticker => 'VOW3.F',
          :category => 'Auto'
      }
  ]

  symbol = params[:symbol]
  s_man = SymbolManager.new(config)
  @symbol_exists = s_man.exists?(symbol)
  @asdg = s_man.securities
  slim :index
end