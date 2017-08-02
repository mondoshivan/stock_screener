require 'stock_screener/symbol_manager'

describe SymbolManager do
  context "#initialize" do
    context "given no values" do
      it "returns the correct object type" do
        expect(SymbolManager.new).to be_kind_of(SymbolManager)
      end
    end
    context "given empty array" do
      it "returns the correct object type" do
        expect(SymbolManager.new([])).to be_kind_of(SymbolManager)
      end
    end
    context "given array with values" do
      it "returns the correct object type" do
        config = [
            {
                :Exchange => "FRA",
                :Name => 'Volkswagen Aktiengesellschaft',
                :Ticker => 'VOW3.F',
                :category => 'Auto'
            }
        ]
        sMan = SymbolManager.new(config)
        expect(sMan.securities[0].name).to eq(config[0][:Name])
      end
    end
  end

  context "#exists?" do
    context "given not existing symbol" do
      it "returns false" do
        sMan = SymbolManager.new
        expect(sMan.exists?('VOW3.F')).to be_falsey
      end
    end

    context "given existing symbol" do
      it "returns true" do
        sMan = SymbolManager.new
        sMan.addSecurity(Security.new('FRA', '', 'VOW3.F'))
        expect(sMan.exists?('VOW3.F')).to be_truthy
      end
    end
  end

  context "#add_security" do
    context "given security" do
      it "adds the sequrity to the sequrities array" do
        sMan = SymbolManager.new
        sMan.addSecurity(Security.new('FRA', '', 'VOW3.F'))
      end
    end
  end
end