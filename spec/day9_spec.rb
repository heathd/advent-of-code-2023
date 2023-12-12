require 'day9'

RSpec.describe "Day9" do
	describe '.differential' do
		it "calculates the first order differential of a sequence of numbers" do
			expect(SequenceAnalyzer.differential([0,3,6,9,12,15])).to eq([3,3,3,3,3])
		end
	end

	describe SequenceAnalyzer do
		subject(:sequence_analyzer) { described_class.new(sequence) }

		context "given a sequence" do
			let(:sequence) { [0,3,6,9,12,15] }

			it "finds all of the differentials until the diff is zero" do
				expect(sequence_analyzer.differentials).to eq([
					[3,3,3,3,3],
					[0,0,0,0]
				])
			end

			it "predicts the next in the sequence" do
				expect(sequence_analyzer.extrapolate).to eq(18)
			end
		end
	end
end
