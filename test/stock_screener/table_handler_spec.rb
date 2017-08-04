require 'stock_screener/table_handler'

describe TableHandler do
  context "#initialize" do
    context "given illegal values" do
      it "uses a default value" do
        sh = TableHandler.new(-1, 0)
        expect(sh.total).to eq(0)

        sh = TableHandler.new(0, -1)
        expect(sh.hits_per_page).to eq(10)

        sh = TableHandler.new(nil, 0)
        expect(sh.total).to eq(0)

        sh = TableHandler.new(0, nil)
        expect(sh.hits_per_page).to eq(10)

      end
    end

    context "lastPage tested" do
      it "returns the correct last page" do
        sh = TableHandler.new(0, 10)
        expect(sh.last_page).to eq(1)

        sh = TableHandler.new(9, 10)
        expect(sh.last_page).to eq(1)

        sh = TableHandler.new(10, 10)
        expect(sh.last_page).to eq(1)

        sh = TableHandler.new(11, 10)
        expect(sh.last_page).to eq(2)

        sh = TableHandler.new(20, 10)
        expect(sh.last_page).to eq(2)

        sh = TableHandler.new(21, 10)
        expect(sh.last_page).to eq(3)
      end
    end
  end

  context "#rangeForPage" do
    context "given invalid values" do
      it "returns a valid range" do
        sh = TableHandler.new(0, 10)
        expect(sh.range_for_page(2)).to eq((0..9))

        sh = TableHandler.new(0, 10)
        expect(sh.range_for_page(0)).to eq((0..9))

        sh = TableHandler.new(0, 10)
        expect(sh.range_for_page(-1)).to eq((0..9))

        sh = TableHandler.new(5, 10)
        expect(sh.range_for_page(2)).to eq((0..9))

        sh = TableHandler.new("5", "10")
        expect(sh.range_for_page("2")).to eq((0..9))
      end
    end

    context "given valid values" do
      it "returns a valid range" do
        sh = TableHandler.new(20, 10)
        expect(sh.range_for_page(1)).to eq((0..9))

        sh = TableHandler.new(20, 10)
        expect(sh.range_for_page(2)).to eq((10..19))

        sh = TableHandler.new(0, 10)
        expect(sh.range_for_page(1)).to eq((0..9))

        sh = TableHandler.new(5, 10)
        expect(sh.range_for_page(1)).to eq((0..9))

        sh = TableHandler.new(9, 10)
        expect(sh.range_for_page(1)).to eq((0..9))

        sh = TableHandler.new(10, 10)
        expect(sh.range_for_page(1)).to eq((0..9))

        sh = TableHandler.new(11, 10)
        expect(sh.range_for_page(1)).to eq((0..9))

        sh = TableHandler.new(11, 10)
        expect(sh.range_for_page(2)).to eq((10..19))
      end
    end
  end

  context "#indicators" do
    context "given valid values" do
      it "returns a valid hash" do
        sh = TableHandler.new(0, 10, 5)
        expect(sh.indicators(1)).to eq({})

        sh = TableHandler.new(10, 10, 5)
        expect(sh.indicators(1)).to eq({})

        sh = TableHandler.new(11, 10, 5)
        expect(sh.indicators(1)).to eq({1 => 1, 2 => 2})

        sh = TableHandler.new(50, 10, 5)
        expect(sh.indicators(1)).to eq(
                                        {1 => 1, 2 => 2, 3 => 3, 4 => 4, 5=> 5}
                                    )

        sh = TableHandler.new(51, 10, 5)
        expect(sh.indicators(1)).to eq(
                                        {1 => 1, 2 => 2, 3 => 3, 4 => 4, '>' => 2}
                                    )

        sh = TableHandler.new(51, 10, 5)
        expect(sh.indicators(6)).to eq(
                                        {'<' => 5, 3 => 3, 4 => 4, 5 => 5, 6 => 6}
                                    )

        sh = TableHandler.new(61, 10, 5)
        expect(sh.indicators(3)).to eq(
                                        {1 => 1, 2 => 2, 3 => 3, 4 => 4, '>' => 4}
                                    )

        sh = TableHandler.new(61, 10, 5)
        expect(sh.indicators(2)).to eq(
                                        {1 => 1, 2 => 2, 3 => 3, 4 => 4, '>' => 3}
                                    )

        sh = TableHandler.new(61, 10, 5)
        expect(sh.indicators(3)).to eq(
                                        {1 => 1, 2 => 2, 3 => 3, 4 => 4, '>' => 4}
                                    )

        sh = TableHandler.new(61, 10, 5)
        expect(sh.indicators(6)).to eq(
                                        {'<' => 5, 4 => 4, 5 => 5, 6 => 6, 7 => 7}
                                    )

        sh = TableHandler.new(61, 10, 5)
        expect(sh.indicators(5)).to eq(
                                        {'<' => 4, 4 => 4, 5 => 5, 6 => 6, 7 => 7}
                                    )

        sh = TableHandler.new(61, 10, 5)
        expect(sh.indicators(4)).to eq(
                                        {'<' => 3, 3 => 3, 4 => 4, 5 => 5, '>' => 5}
                                    )
      end
    end
  end

end