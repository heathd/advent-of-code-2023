class Navigator
	attr_reader :input, :lines

	def initialize(input)
		@input = input
		@lines = input.split("\n")
	end

	def instructions
		instructions = lines.first
		raise "Illegal instruction" unless valid_instructions?(instructions)
		instructions
	end

	def valid_instructions?(i)
		i.chars.all? {|c| %w{L R}.include?(c)}
	end

	def instructions_enumerator
		Enumerator.new do |enum|
	    i = 0
	    while true
	      enum.yield(instructions[i % instructions.size])
	      i += 1
	    end
	  end
	end

	def nodes
		@nodes ||= begin
			as_array = lines[2..-1].map do |line|
				line =~ /^([^ ]+) = \(([^ ]+), ([^ ]+)\)/
				[$1, [$2, $3]]
			end
			Hash[as_array]
		end
	end

	def path_to_zzz
		i = instructions_enumerator
		path = []

		current = "AAA"
		while current != "ZZZ"
			instruction = i.next
			current = if instruction == "R"
				nodes[current][1]
			elsif instruction == "L"
				nodes[current][0]
			else
				raise "Illegal instruction '#{instruction}'"
			end
			path << current
		end
		path
	end
end

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
