require 'day7/hand'

class CamelCards
  attr_reader :hands, :joker_rule
  
  def initialize(joker_rule: false)
    @hands = []
    @joker_rule = joker_rule
  end

  def add_hand(hand, bid)
    @hands << {
      hand: Hand.new(hand, joker_rule: joker_rule),
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