require 'stock_screener/helpers/security_helpers'

describe SecurityHelpers do
  let(:extended_class) { Class.new { extend SecurityHelpers } }

  context "#get_number" do
    context "given billion value" do
      it "returns a float" do
        string = "234B"
        expect(extended_class.get_number_from_string(string)).to be 234000000000.0
      end

      it "returns an float" do
        string = "2.34B"
        expect(extended_class.get_number_from_string(string)).to be 2340000000.0
      end
    end

    context "given million value" do
      it "returns a float" do
        string = "234M"
        expect(extended_class.get_number_from_string(string)).to be 234000000.0
      end

      it "returns an float" do
        string = "2.34M"
        expect(extended_class.get_number_from_string(string)).to be 2340000.0
      end
    end

    context "given low value" do
      it "returns a float" do
        string = "234"
        expect(extended_class.get_number_from_string(string)).to be 234.0
      end

      it "returns an float" do
        string = "2.34"
        expect(extended_class.get_number_from_string(string)).to be 2.34
      end
    end

    context "given negative value" do
      it "returns a float" do
        string = "-234"
        expect(extended_class.get_number_from_string(string)).to be -234.0
      end

      it "returns a float" do
        string = "-2.34"
        expect(extended_class.get_number_from_string(string)).to be -2.340
      end
    end

    context "given zero value" do
      it "returns a float" do
        string = "0"
        expect(extended_class.get_number_from_string(string)).to be 0.0
      end
    end

    context "given value with comma seperation" do
      it "returns a float" do
        string = "234,234,000"
        expect(extended_class.get_number_from_string(string)).to be 234234000.0
      end
    end
  end

  context "#get_string" do
    context "given billion value" do
      it "returns an float" do
        number = 2340000000.0
        expect(extended_class.get_string_from_number(number)).to eq '2,34B'
      end

      it "returns an float" do
        number = 234000000000.0
        expect(extended_class.get_string_from_number(number)).to eq '234B'
      end
    end

    context "given million value" do
      it "returns an float" do
        number = 2340000.0
        expect(extended_class.get_string_from_number(number)).to eq '2,34M'
      end

      it "returns an float" do
        number = 234000000.0
        expect(extended_class.get_string_from_number(number)).to eq '234M'
      end
    end

    context "given low value" do
      it "returns an float" do
        number = 2.34
        expect(extended_class.get_string_from_number(number)).to eq '2,34'
      end

      it "returns an float" do
        number = 234.0
        expect(extended_class.get_string_from_number(number)).to eq '234'
      end
    end

    context "given negative value" do
      it "returns an float" do
        number = -2.34
        expect(extended_class.get_string_from_number(number)).to eq '-2,34'
      end

      it "returns an float" do
        number = -234.0
        expect(extended_class.get_string_from_number(number)).to eq '-234'
      end
    end

    context "given zero value" do
      it "returns an float" do
        number = 0
        expect(extended_class.get_string_from_number(number)).to eq '0'
      end
    end
  end
end