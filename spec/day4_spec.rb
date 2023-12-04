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

private
	def as_numbers(text_list)
		text_list.split(" ").reject(&:empty?).map(&:to_i)
	end
end

class ScratchCardScorer
	def score(card)
		ScratchCard.new(card)
	end
end

RSpec.describe ScratchCard do
	subject(:scratchcard) { described_class.new(card) }

	context "card with only one winning number" do
		let(:card) { "Card 1: 1 | 2" }
		
		it "can list the winning numbers" do
			expect(scratchcard.winning_numbers).to eq([1])
		end

		it "can list the numbers you have" do
			expect(scratchcard.numbers_you_have).to eq([2])
		end

		it "can list the winning numbers you have" do
			expect(scratchcard.winning_numbers_you_have).to eq([])
		end
	end

	context "card with list of winning numbers" do
		let(:card) { "Card 1: 41 48 83 86 17 | 83 86  6 31 17  9 48 53" }
		
		it "can list the winning numbers" do
			expect(scratchcard.winning_numbers).to eq([41,48,83,86,17])
		end

		it "can list the numbers you have" do
			expect(scratchcard.numbers_you_have).to eq([83,86,6,31,17,9,48,53])
		end

		it "can list the winning numbers you have" do
			expect(scratchcard.winning_numbers_you_have).to contain_exactly(48,83,86,17)
		end
	end


end