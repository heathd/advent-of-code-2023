require 'day7/hand'

RSpec.describe Hand do
  it "can construct a hand" do
    hand = Hand.new("32T3K")
    expect(hand.hand).to eq("32T3K")
  end

  it "can be compared" do
    expect(Hand.new("32T3K")).to eq(Hand.new("32T3K"))
  end

  describe "#counts" do
    it "counts the number of each type of card in the hand" do
      expect(Hand.new("AAAAA").counts).to eq([["A", 5]])
      expect(Hand.new("AAAA2").counts).to eq([["A", 4], ["2", 1]])
      expect(Hand.new("AAAT2").counts).to eq([["A", 3], ["T", 1], ["2", 1]])
    end

    context "with joker rule" do
      it "counts jokers along with the card that will give five of a kind" do
        expect(Hand.new("AAAAA", joker_rule: true).counts).to eq([["A", 5]])
        expect(Hand.new("AAAAJ", joker_rule: true).counts).to eq([["A", 5]])
        expect(Hand.new("AAAJJ", joker_rule: true).counts).to eq([["A", 5]])
        expect(Hand.new("AAJJJ", joker_rule: true).counts).to eq([["A", 5]])
        expect(Hand.new("AJJJJ", joker_rule: true).counts).to eq([["A", 5]])
        expect(Hand.new("JJJJJ", joker_rule: true).counts).to eq([["J", 5]])
      end

      it "counts jokers along with the card that will give the strongest four of a kind" do
        expect(Hand.new("3AAAA", joker_rule: true).counts).to eq([["A", 4], ["3", 1]])
        expect(Hand.new("3AAAJ", joker_rule: true).counts).to eq([["A", 4], ["3", 1]])
        expect(Hand.new("3AAJJ", joker_rule: true).counts).to eq([["A", 4], ["3", 1]])
        expect(Hand.new("3AJJJ", joker_rule: true).counts).to eq([["A", 4], ["3", 1]])
      end

      it "counts jokers along with the card that will give the strongest three of a kind" do
        expect(Hand.new("32AAA", joker_rule: true).counts).to eq([["A", 3], ["3", 1], ["2", 1]])
        expect(Hand.new("32AAJ", joker_rule: true).counts).to eq([["A", 3], ["3", 1], ["2", 1]])
        expect(Hand.new("32AJJ", joker_rule: true).counts).to eq([["A", 3], ["3", 1], ["2", 1]])
      end

      it "counts jokers along with the cards that will create a full house" do
        expect(Hand.new("3322J", joker_rule: true).counts).to eq([["3", 3], ["2", 2]])
        expect(Hand.new("J3223", joker_rule: true).counts).to eq([["3", 3], ["2", 2]])
      end

      it "counts jokers along with the cards that will create a pair" do
        expect(Hand.new("3456J", joker_rule: true).counts).to eq([["6", 2], ["3", 1], ["4", 1], ["5", 1]])
      end
    end
  end

  describe "identifying type of hand" do
    it "can identify five of a kind" do
      expect(Hand.new("AAAAA").type).to eq(:five_of_a_kind)
      expect(Hand.new("KKKKK").type).to eq(:five_of_a_kind)
      expect(Hand.new("QQQQQ").type).to eq(:five_of_a_kind)
      expect(Hand.new("JJJJJ").type).to eq(:five_of_a_kind)
      expect(Hand.new("TTTTT").type).to eq(:five_of_a_kind)
      expect(Hand.new("99999").type).to eq(:five_of_a_kind)
      expect(Hand.new("88888").type).to eq(:five_of_a_kind)
      expect(Hand.new("77777").type).to eq(:five_of_a_kind)
      expect(Hand.new("66666").type).to eq(:five_of_a_kind)
      expect(Hand.new("55555").type).to eq(:five_of_a_kind)
      expect(Hand.new("44444").type).to eq(:five_of_a_kind)
      expect(Hand.new("33333").type).to eq(:five_of_a_kind)
      expect(Hand.new("22222").type).to eq(:five_of_a_kind)
    end

    it "can identify four of a kind" do
      expect(Hand.new("AAAA2").type).to eq(:four_of_a_kind)
      expect(Hand.new("AAA2A").type).to eq(:four_of_a_kind)
      expect(Hand.new("AA2AA").type).to eq(:four_of_a_kind)
      expect(Hand.new("A2AAA").type).to eq(:four_of_a_kind)
      expect(Hand.new("2AAAA").type).to eq(:four_of_a_kind)
    end

    it "can identify full house" do
      expect(Hand.new("AAA22").type).to eq(:full_house)
      expect(Hand.new("AA22A").type).to eq(:full_house)
      expect(Hand.new("A22AA").type).to eq(:full_house)
      expect(Hand.new("22AAA").type).to eq(:full_house)
    end

    it "can identify three of a kind" do
      expect(Hand.new("AAA23").type).to eq(:three_of_a_kind)
      expect(Hand.new("AA23A").type).to eq(:three_of_a_kind)
      expect(Hand.new("A23AA").type).to eq(:three_of_a_kind)
      expect(Hand.new("23AAA").type).to eq(:three_of_a_kind)
    end

    it "can identify two pair" do
      expect(Hand.new("AA223").type).to eq(:two_pair)
      expect(Hand.new("A22A3").type).to eq(:two_pair)
      expect(Hand.new("A23A2").type).to eq(:two_pair)
    end

    it "can identify one pair" do
      expect(Hand.new("AA234").type).to eq(:one_pair)
      expect(Hand.new("A4A23").type).to eq(:one_pair)
      expect(Hand.new("4A23A").type).to eq(:one_pair)
    end

    it "can identify high card" do
      expect(Hand.new("A5234").type).to eq(:high_card)
    end
  end
  
  describe "computing a ranking for a hand" do
    it "calculates a ranking based on the type of hand" do
      expect(Hand.new("AAAAA").card_type_strength).to eq(1)
      expect(Hand.new("2AAAA").card_type_strength).to eq(2)
      expect(Hand.new("22AAA").card_type_strength).to eq(3)
      expect(Hand.new("24AAA").card_type_strength).to eq(4)
      expect(Hand.new("A22A4").card_type_strength).to eq(5)
      expect(Hand.new("4A23A").card_type_strength).to eq(6)
      expect(Hand.new("A5234").card_type_strength).to eq(7)
    end

    it "calculates a ranking based on cards in the hand" do
      expect(Hand.new("AAAAA").card_strength).to eq([1, 1, 1, 1, 1])
      expect(Hand.new("2AAAA").card_strength).to eq([13, 1, 1, 1, 1])
      expect(Hand.new("22AAA").card_strength).to eq([13, 13, 1, 1, 1])
      expect(Hand.new("24AAA").card_strength).to eq([13, 11, 1, 1, 1])
      expect(Hand.new("A22A4").card_strength).to eq([1, 13, 13, 1, 11])
      expect(Hand.new("4A23A").card_strength).to eq([11, 1, 13, 12, 1])
      expect(Hand.new("A5234").card_strength).to eq([1, 10, 13, 12, 11])
    end

    context "joker rule" do
      it "treats joker as the weakest card" do
        expect(Hand.new("AAAAJ", joker_rule: true).card_strength).to eq([1, 1, 1, 1, 13])
      end
    end
  end

  describe "ordering using <=>" do
    it "can compare the ordering of two hands" do
      expect(Hand.new("AAAAA") <=> Hand.new("KKKKK")).to eq(-1)
      expect(Hand.new("AAAAA") <=> Hand.new("AAAAK")).to eq(-1)
      expect(Hand.new("AAAAA") <=> Hand.new("AAAAA")).to eq(0)
      expect(Hand.new("QQQQQ") <=> Hand.new("AAAAQ")).to eq(-1)
      expect(Hand.new("QQQQA") <=> Hand.new("AAAQQ")).to eq(-1)
      expect(Hand.new("QQQAA") <=> Hand.new("AAAQK")).to eq(-1)
    end
  end
end