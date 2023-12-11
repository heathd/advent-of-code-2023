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