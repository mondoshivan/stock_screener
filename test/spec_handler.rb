#!/usr/bin/env rspec

lib = File.expand_path("../../test", __FILE__)
$:.unshift(lib) unless $:.include?(lib)

require 'stock_screener/security_spec'
require 'stock_screener/symbol_manager_spec'