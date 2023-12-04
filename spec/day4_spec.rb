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
	def score(card)
		ScratchCard.new(card)
	end
end

RSpec.describe ScratchCard do
	subject(:scratchcard) { described_class.new(card) }

	context "card with one winning number, none that you have" do
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

		it "scores zero" do
			expect(scratchcard.score).to eq(0)
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

		it "can calculate score" do
			expect(scratchcard.score).to eq(8)
		end
	end

	describe ".score_for" do
		it "scores 0 for no winning numbers, 1 for one winning number, doubles after that" do
			expect(ScratchCard.score_for(winning_numbers: 0)).to eq(0)
			expect(ScratchCard.score_for(winning_numbers: 1)).to eq(1)
			expect(ScratchCard.score_for(winning_numbers: 2)).to eq(2)
			expect(ScratchCard.score_for(winning_numbers: 3)).to eq(4)
			expect(ScratchCard.score_for(winning_numbers: 4)).to eq(8)
			expect(ScratchCard.score_for(winning_numbers: 5)).to eq(16)
		end
	end
end