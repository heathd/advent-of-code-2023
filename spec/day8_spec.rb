RSpec.describe Navigator do
	it "can parse instructions" do
		expect(Navigator.new("RL").instructions).to eq("RL")
		expect(Navigator.new("R").instructions).to eq("R")
	end

	it "rejects illegal instructions" do
		expect {Navigator.new(" ").instructions}.to raise_error("Illegal instruction")
	end

	it "can parse nodes" do
		expect(Navigator.new("RL\n\nAAA = (BBB, CCC)\n").nodes).to eq({"AAA" => ["BBB", "CCC"]})
	end

	context "the example given in the exercise description" do
		subject(:navigator) {described_class.new(input)}
		
		let(:input) {
			<<~MAP
			RL

			AAA = (BBB, CCC)
			BBB = (DDD, EEE)
			CCC = (ZZZ, GGG)
			DDD = (DDD, DDD)
			EEE = (EEE, EEE)
			GGG = (GGG, GGG)
			ZZZ = (ZZZ, ZZZ)
			MAP
		}

		it "can follow instructions until it reaches ZZZ" do
			expect(navigator.path_to_zzz).to eq(%w{
				CCC
				ZZZ
			})
		end
	end

	context "a second example" do
		subject(:navigator) {described_class.new(input)}
		
		let(:input) {
			<<~MAP
			LLR

			AAA = (BBB, BBB)
			BBB = (AAA, ZZZ)
			ZZZ = (ZZZ, ZZZ)
			MAP
		}

		it "can follow instructions until it reaches ZZZ" do
			expect(navigator.path_to_zzz).to eq(%w{
				BBB
				AAA
				BBB
				AAA
				BBB
				ZZZ
			})
		end

	end

end
