require 'day7/hand'
require 'day7/camel_cards'

RSpec.describe CamelCards do
  subject(:game) { described_class.new }
  before(:each) do
    game.add_hand("32T3K", 765)
    game.add_hand("T55J5", 684)
    game.add_hand("KK677", 28)
    game.add_hand("KTJJT", 220)
    game.add_hand("QQQJA", 483)
  end

  it "can rank hands" do

    expect(game.rank).to eq(
      [
        Hand.new("QQQJA"),
        Hand.new("T55J5"),
        Hand.new("KK677"),
        Hand.new("KTJJT"),
        Hand.new("32T3K")
      ]
    )
  end

  it "can calculate total winnings" do
    expect(game.total_winnings).to eq(6440)
  end
end