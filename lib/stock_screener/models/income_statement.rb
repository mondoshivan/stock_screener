require 'dm-core'
require 'dm-migrations'



class IncomeStatement

  PERIOD = {
      :quarterly => 'quaterly',
      :yearly => 'yearly'
  }

  include DataMapper::Resource

  property :id, Serial
  property :period, String
  property :date, Date

  # Revenue
  property :total_revenue, Float
  property :cost_of_revenue, Float
  property :gross_profit, Float

  # Operating Expenses
  property :research_development, Float
  property :selling_general_and_administrative, Float
  property :non_recurring, Float
  property :others, Float
  property :total_operating_expenses, Float
  property :operating_income_or_loss, Float

  # Income from Continuing Operations
  property :total_other_income_expenses_net, Float
  property :earnings_before_interest_and_taxes, Float
  property :interest_expense, Float
  property :income_before_tax, Float
  property :income_tax_expense, Float
  property :minority_interest, Float
  property :net_income_from_continuing_ops, Float

  # Non-recurring Events
  property :discontinued_operations, Float
  property :extraordinary_items, Float
  property :effect_of_accounting_changes, Float
  property :other_items, Float

  # Net Income
  property :net_income, Float
  property :preferred_stock_and_other_adjustments, Float
  property :net_income_applicable_to_common_shares, Float

  belongs_to :security

end
