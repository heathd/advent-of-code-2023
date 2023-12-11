class Hand
  attr_reader :hand

  def initialize(hand)
    @hand = hand
    validate_hand!
  end

  def cards
    @hand.chars
  end

  def counts
    cards.group_by {|c| c}.map {|c, l| [c, l.size]}.sort_by {|card, count| -count}
  end

  def type
    _, count_of_most_common_card = counts.first
    if count_of_most_common_card == 5
      :five_of_a_kind
    elsif count_of_most_common_card == 4
      :four_of_a_kind
    elsif count_of_most_common_card == 3
      _, count_of_second_most_common_card = counts[1]
      if count_of_second_most_common_card == 2
        :full_house
      else
        :three_of_a_kind
      end
    elsif count_of_most_common_card == 2
      _, count_of_second_most_common_card = counts[1]
      if count_of_second_most_common_card == 2
        :two_pair
      else
        :one_pair
      end
    else
      :high_card
    end
  end


  def rank_indicator
    [card_type_strength] + card_strength
  end

  def <=>(other)
    rank_indicator <=> other.rank_indicator
  end

  CARD_TYPES = %I{
    five_of_a_kind
    four_of_a_kind
    full_house
    three_of_a_kind
    two_pair
    one_pair
    high_card
  }

  def card_type_strength
    CARD_TYPES.find_index(type) + 1
  end

  CARDS = %w{A K Q J T 9 8 7 6 5 4 3 2}

  def card_strength
    cards.map {|card| CARDS.find_index(card) + 1}
  end

  def validate_hand!
    illegal_cards = cards.reject {|c| CARDS.include?(c)}

    if illegal_cards.any?
      raise "Illegal card(s) #{illegal_cards.inspect}"
    end

    if cards.size != 5
      raise "Wrong number of cards #{cards.size} should have 5"
    end
  end

  def ==(other)
    self.hand == other.hand
  end
end
