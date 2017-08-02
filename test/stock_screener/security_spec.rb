require 'stock_screener/security'

describe Security do
  context "#initialize" do
    context "given no values" do
      it "returns the correct object type" do
        expect(Security.new).to be_kind_of(Security)
      end
    end

    context "given values" do
      it "stores the values correctly" do
        exchange = 'FRA'
        name = 'Volkswagen Aktiengesellschaft'
        symbol = 'VOW3.F'
        category = 'Auto'
        security = Security.new(exchange, name, symbol, category)

        expect(security.exchange).to eq(exchange)
        expect(security.name).to eq(name)
        expect(security.symbol).to eq(symbol)
        expect(security.category).to eq(category)
      end
    end
  end
end