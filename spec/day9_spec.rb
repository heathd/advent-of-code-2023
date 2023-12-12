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

      it "predicts the previous in the sequence" do
        expect(sequence_analyzer.extrapolate_backwards).to eq(-3)
      end
    end

    context "given another sequence" do
      let(:sequence) { %w{10 15 15 10 0 -15 -35 -60 -90 -125 -165 -210 -260 -315 -375 -440 -510 -585 -665 -750 -840
}.map(&:to_i) }

      it "finds all of the differentials until the diff is zero" do
        expect(sequence_analyzer.differentials).to eq([
          [5, 0, -5, -10, -15, -20, -25, -30, -35, -40, -45, -50, -55, -60, -65, -70, -75, -80, -85, -90],
          [-5, -5, -5, -5, -5, -5, -5, -5, -5, -5, -5, -5, -5, -5, -5, -5, -5, -5, -5],
          [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
        ])
      end

      it "predicts the previous in the sequence" do
        #  0   10  15  15   10
        #    10   5   0   -5
        #      -5  -5  -5
        #         0   0
        #  0  
        # 10 <= 5, 
        # -5 <= -5,
        #    <= 0, 
        # pp sequence_analyzer.differentials
        expect(sequence_analyzer.extrapolate_backwards).to eq(0)
      end
    end
  end
end
