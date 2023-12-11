class ScratchCard
  attr_reader :card_text

  def initialize(card_text)
    @card_text = card_text
    @card_number_text, @scoring = card_text.split(": ")
    @winning_numbers_text, @numbers_you_have_text = @scoring.split("|")
  end

  def winning_numbers
    as_numbers(@winning_numbers_text)
  end

  def numbers_you_have
    as_numbers(@numbers_you_have_text)
  end

  def winning_numbers_you_have
    winning_numbers.select {|n| numbers_you_have.include?(n)}
  end

  def score
    self.class.score_for(winning_numbers: winning_numbers_you_have.size)
  end

  def self.score_for(winning_numbers: )
    if winning_numbers == 0
      0
    else
      2 ** (winning_numbers - 1)
    end
  end

private
  def as_numbers(text_list)
    text_list.split(" ").reject(&:empty?).map(&:to_i)
  end
end

class ScratchCardScorer
  def initialize(cards)
    @cards = cards
      .split("\n")
      .reject(&:empty?)
      .map {|line| ScratchCard.new(line) }
  end

  def score
    @cards.map(&:score).inject(&:+)
  end

  def number_of_winning_scratchcards

    copies_by_card = {}
    @cards.each.with_index do |card, i|
      copies_by_card[i] = 1
    end

    @cards.each.with_index do |card, i|
      num_copies = copies_by_card[i]
      number_of_subsequent_cards_to_copy = card.winning_numbers_you_have.size
      (i+1...(i+1+number_of_subsequent_cards_to_copy)).each do |index_to_copy|
        copies_by_card[index_to_copy] += num_copies unless index_to_copy >= @cards.size
      end
    end

    copies_by_card.values.inject(&:+)
  end
end

if __FILE__==$0
  puts ScratchCardScorer.new(ARGF.read).score
end
