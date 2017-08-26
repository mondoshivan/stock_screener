require 'dm-core'
require 'dm-migrations'



class BalanceSheet

  PERIOD = {
      :quarterly => 'quaterly',
      :yearly => 'yearly'
  }

  include DataMapper::Resource

  property :id, Serial
  property :period, String
  property :date, Date

  # Current Assets
  property :cash_and_cash_equivalents, Float
  property :short_term_investments, Float
  property :net_receivables, Float
  property :inventory, Float
  property :other_current_assets, Float
  property :total_current_assets, Float
  property :long_term_investments, Float
  property :property_plant_and_equipment, Float
  property :goodwill, Float
  property :intangible_assets, Float
  property :accumulated_amortization, Float
  property :other_assets, Float
  property :deferred_long_term_asset_charges, Float
  property :total_assets, Float

  # Current Liabilities
  property :accounts_payable, Float
  property :short_current_long_term_debt, Float
  property :other_current_liabilities, Float
  property :total_current_liabilities, Float
  property :long_term_debt, Float
  property :other_liabilities, Float
  property :deferred_long_term_liability_charges, Float
  property :minority_interest, Float
  property :negative_goodwill, Float
  property :total_liabilities, Float

  # Stockholders' Equity
  property :misc_stocks_options_warrants, Float
  property :redeemable_preferred_stock, Float
  property :preferred_stock, Float
  property :common_stock, Float
  property :retained_earnings, Float
  property :treasury_stock, Float
  property :capital_surplus, Float
  property :other_stockholder_equity, Float
  property :total_stockholder_equity, Float
  property :net_tangible_assets, Float


  belongs_to :security

end
