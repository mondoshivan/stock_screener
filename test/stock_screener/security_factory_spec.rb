require 'stock_screener/security_factory'

describe SecurityFactory do
  context "#initialize" do
    context "given no values" do
      it "returns the correct object type" do
        expect(SecurityFactory.new).to be_kind_of(SecurityFactory)
      end
    end
    context "given array" do
      it "returns the correct object type" do
        expect(SecurityFactory.new([])).to be_kind_of(SecurityFactory)
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
        SecurityFactory.new(config)
        expect(Security.all.count).to eq(config.length)
      end
    end
  end

  context "#get" do
    context "given valid values" do
      it "returns the correct security" do
        config = [
            {
                :Exchange => "FRA",
                :Name => 'Volkswagen Aktiengesellschaft',
                :Ticker => 'VOW3.F',
                :category => 'Auto'
            }
        ]
        sf = SecurityFactory.new(config)
        expect(sf.get_with_id(1).symbol).to eq(config[0][:Ticker])
      end
    end
  end

  # context "#exists?" do
  #   context "given not existing symbol" do
  #     it "returns false" do
  #       sMan = SecurityFactory.new
  #       expect(sMan.exists?('VOW3.F')).to be_falsey
  #     end
  #   end
  #
  #   context "given existing symbol" do
  #     it "returns true" do
  #       sMan = SecurityFactory.new
  #       sMan.addSecurity(Security.new('FRA', '', 'VOW3.F'))
  #       expect(sMan.exists?('VOW3.F')).to be_truthy
  #     end
  #   end
  # end

end