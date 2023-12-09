require 'day4'

RSpec.describe ScratchCardScorer do
	subject(:scratchcard_scorer) { described_class.new(cards) }

	context "part 1" do
		let(:cards) {
			<<~CARDS
				Card 1: 41 48 83 86 17 | 83 86  6 31 17  9 48 53
				Card 2: 13 32 20 16 61 | 61 30 68 82 17 32 24 19
				Card 3:  1 21 53 59 44 | 69 82 63 72 16 21 14  1
				Card 4: 41 92 73 84 69 | 59 84 76 51 58  5 54 83
				Card 5: 87 83 26 28 32 | 88 30 70 12 93 22 82 36
				Card 6: 31 18 13 56 72 | 74 77 10 23 35 67 36 11
			CARDS
		}

		it "can score many cards" do
			expect(scratchcard_scorer.score).to eq(13)
		end
	end

	describe "#number_of_winning_scratchcards" do
		context "only one card with no winning numbers" do

			let(:cards) {
				<<~CARDS
					Card 1: 1 | 2
				CARDS
			}

			it "scores one" do
				expect(scratchcard_scorer.number_of_winning_scratchcards).to eq(1)
			end
		end

		it "scores two with only two cards with no winners" do
			cards = <<~CARDS
				Card 1: 1 | 2
				Card 2: 1 | 2
			CARDS

			scorer = described_class.new(cards)
			expect(scorer.number_of_winning_scratchcards).to eq(2)
		end

		it "scores three when the first card has a winner" do
			cards = <<~CARDS
				Card 1: 1 | 1
				Card 2: 1 | 2
			CARDS

			scorer = described_class.new(cards)
			expect(scorer.number_of_winning_scratchcards).to eq(3)
		end

		it "scores two when the second card has a winner" do
			cards = <<~CARDS
				Card 1: 1 | 2
				Card 2: 1 | 1
			CARDS

			scorer = described_class.new(cards)
			expect(scorer.number_of_winning_scratchcards).to eq(2)
		end

		it "scores 5 in this scenario" do
			cards = <<~CARDS
				Card 1: 1 2 | 1 2
				Card 2: 3 | 4
				Card 3: 5 | 6
			CARDS

			scorer = described_class.new(cards)
			expect(scorer.number_of_winning_scratchcards).to eq(5)
		end

		it "scores 30 in this scenario" do
			cards = <<~CARDS
				Card 1: 41 48 83 86 17 | 83 86  6 31 17  9 48 53
				Card 2: 13 32 20 16 61 | 61 30 68 82 17 32 24 19
				Card 3:  1 21 53 59 44 | 69 82 63 72 16 21 14  1
				Card 4: 41 92 73 84 69 | 59 84 76 51 58  5 54 83
				Card 5: 87 83 26 28 32 | 88 30 70 12 93 22 82 36
				Card 6: 31 18 13 56 72 | 74 77 10 23 35 67 36 11
			CARDS

			scorer = described_class.new(cards)
			expect(scorer.number_of_winning_scratchcards).to eq(30)
		end
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