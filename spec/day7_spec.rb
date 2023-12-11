require 'day7/hand'

class CamelCards
  def initialize
    @hands = []
  end

  def add_hand(hand, bid)
    @hands << {
      hand: Hand.new(hand),
      bid: bid
    }
  end

  def rank
    @hands.map {|h| h[:hand]}.sort
  end

  def total_winnings
    sorted = @hands.sort_by {|h| h[:hand]}.reverse
    sorted.each.with_index.inject(0) do |memo, (hand_rec, i)|
      memo + hand_rec[:bid] * (i+1)
    end
  end
end

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