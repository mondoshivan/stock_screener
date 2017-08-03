require 'stock_screener/search_handler'

describe SearchHandler do
  context "#initialize" do
    context "given illegal values" do
      it "uses a default value" do
        sh = SearchHandler.new(-1, 0)
        expect(sh.total).to eq(0)

        sh = SearchHandler.new(0, -1)
        expect(sh.hitsPerPage).to eq(10)

        sh = SearchHandler.new(nil, 0)
        expect(sh.total).to eq(0)

        sh = SearchHandler.new(0, nil)
        expect(sh.hitsPerPage).to eq(10)

      end
    end

    context "lastPage tested" do
      it "returns the correct last page" do
        sh = SearchHandler.new(0, 10)
        expect(sh.lastPage).to eq(1)

        sh = SearchHandler.new(9, 10)
        expect(sh.lastPage).to eq(1)

        sh = SearchHandler.new(10, 10)
        expect(sh.lastPage).to eq(1)

        sh = SearchHandler.new(11, 10)
        expect(sh.lastPage).to eq(2)

        sh = SearchHandler.new(20, 10)
        expect(sh.lastPage).to eq(2)

        sh = SearchHandler.new(21, 10)
        expect(sh.lastPage).to eq(3)
      end
    end
  end

  context "#rangeForPage" do
    context "given invalid values" do
      it "returns a valid range" do
        sh = SearchHandler.new(0, 10)
        expect(sh.rangeForPage(2)).to eq((0..9))

        sh = SearchHandler.new(0, 10)
        expect(sh.rangeForPage(0)).to eq((0..9))

        sh = SearchHandler.new(0, 10)
        expect(sh.rangeForPage(-1)).to eq((0..9))

        sh = SearchHandler.new(5, 10)
        expect(sh.rangeForPage(2)).to eq((0..9))

        sh = SearchHandler.new("5", "10")
        expect(sh.rangeForPage("2")).to eq((0..9))
      end
    end

    context "given valid values" do
      it "returns a valid range" do
        sh = SearchHandler.new(20, 10)
        expect(sh.rangeForPage(1)).to eq((0..9))

        sh = SearchHandler.new(20, 10)
        expect(sh.rangeForPage(2)).to eq((10..19))

        sh = SearchHandler.new(0, 10)
        expect(sh.rangeForPage(1)).to eq((0..9))

        sh = SearchHandler.new(5, 10)
        expect(sh.rangeForPage(1)).to eq((0..9))

        sh = SearchHandler.new(9, 10)
        expect(sh.rangeForPage(1)).to eq((0..9))

        sh = SearchHandler.new(10, 10)
        expect(sh.rangeForPage(1)).to eq((0..9))

        sh = SearchHandler.new(11, 10)
        expect(sh.rangeForPage(1)).to eq((0..9))

        sh = SearchHandler.new(11, 10)
        expect(sh.rangeForPage(2)).to eq((10..19))
      end
    end
  end

  context "#indicators" do
    context "given valid values" do
      it "returns a valid hash" do
        sh = SearchHandler.new(0, 10, 5)
        expect(sh.indicators(1)).to eq({})

        sh = SearchHandler.new(10, 10, 5)
        expect(sh.indicators(1)).to eq({})

        sh = SearchHandler.new(11, 10, 5)
        expect(sh.indicators(1)).to eq({1 => 1, 2 => 2})

        sh = SearchHandler.new(50, 10, 5)
        expect(sh.indicators(1)).to eq(
                                        {1 => 1, 2 => 2, 3 => 3, 4 => 4, 5=> 5}
                                    )

        sh = SearchHandler.new(51, 10, 5)
        expect(sh.indicators(1)).to eq(
                                        {1 => 1, 2 => 2, 3 => 3, 4 => 4, 5 => '>'}
                                    )

        sh = SearchHandler.new(51, 10, 5)
        expect(sh.indicators(5)).to eq(
                                        {1 => '<', 2 => 2, 3 => 3, 4 => 4, 5 => 5}
                                    )

        sh = SearchHandler.new(61, 10, 5)
        expect(sh.indicators(3)).to eq(
                                        {1 => '<', 2 => 2, 3 => 3, 4 => 4, 5 => '>'}
                                    )
      end
    end
  end

end