class Hand
  attr_reader :hand, :joker_rule

  def initialize(hand, joker_rule: false)
    @hand = hand
    @joker_rule = joker_rule

    validate_hand!
  end

  def cards
    @hand.chars
  end

  def counts
    counts = cards.group_by {|c| c}.map {|c, l| [c, l.size]}.sort_by {|card, count| -count}
    if joker_rule
      _, num_jokers = counts.find { |card, count| card == "J"} || ["", 0]

      rest = counts.reject {|card, count| card == "J"}

      if rest.empty?
        [["J", num_jokers]]
      else
        _, frequency_of_next_most_common_card = rest.first

        choices_to_match_joker_with = rest.select {|c,count| count == frequency_of_next_most_common_card}
        most_common_card, most_common_card_count = choices_to_match_joker_with.sort_by {|c, _| CARDS.find_index(c)}.first

        [[most_common_card, most_common_card_count+num_jokers]] + rest.reject {|c, _| c == most_common_card}
      end
    else
      counts
    end
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
  CARDS_FOR_JOKER_RULE = %w{A K Q T 9 8 7 6 5 4 3 2 J}

  def card_strength
    mapping = joker_rule ? CARDS_FOR_JOKER_RULE : CARDS
    cards.map {|card| mapping.find_index(card) + 1}
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
