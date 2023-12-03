require 'day3'

RSpec.describe EngineToken do
	let(:ypos) { 0 }
	describe "determining the overlap between two EngineTokens" do
		it "is considered to touch if they are horizontally adjacent on the same line" do
			t1 = EngineToken.new(0,0,ypos)
			t2 = EngineToken.new(1,1,ypos)
			t3 = EngineToken.new(2,2,ypos)

			expect(t1.touches?(t2)).to eq(true)
			expect(t2.touches?(t1)).to eq(true)

			expect(t1.touches?(t3)).to eq(false)
			expect(t3.touches?(t1)).to eq(false)

			expect(t2.touches?(t3)).to eq(true)
			expect(t3.touches?(t2)).to eq(true)
		end

		it "is considered to touch if they are vertically adjacent" do
			t1 = EngineToken.new(0,0,0)
			t2 = EngineToken.new(0,0,1)
			t3 = EngineToken.new(0,0,2)

			expect(t1.touches?(t2)).to eq(true)
			expect(t2.touches?(t1)).to eq(true)

			expect(t1.touches?(t3)).to eq(false)
			expect(t3.touches?(t1)).to eq(false)

			expect(t2.touches?(t3)).to eq(true)
			expect(t3.touches?(t2)).to eq(true)
		end

		it "is considered to touch if they are diagonally adjacent from top left to bottom right" do
			t1 = EngineToken.new(0,0,0)
			t2 = EngineToken.new(1,1,1)
			t3 = EngineToken.new(2,2,2)

			expect(t1.touches?(t2)).to eq(true)
			expect(t2.touches?(t1)).to eq(true)

			expect(t1.touches?(t3)).to eq(false)
			expect(t3.touches?(t1)).to eq(false)

			expect(t2.touches?(t3)).to eq(true)
			expect(t3.touches?(t2)).to eq(true)
		end

		it "is considered to touch if they are diagonally adjacent from top right to bottom left" do
			t1 = EngineToken.new(2,2,0)
			t2 = EngineToken.new(1,1,1)
			t3 = EngineToken.new(0,0,2)

			expect(t1.touches?(t2)).to eq(true)
			expect(t2.touches?(t1)).to eq(true)

			expect(t1.touches?(t3)).to eq(false)
			expect(t3.touches?(t1)).to eq(false)

			expect(t2.touches?(t3)).to eq(true)
			expect(t3.touches?(t2)).to eq(true)
		end
	end
end

RSpec.describe EngineSchematicParser do
	subject(:engine_schematic_parser) { described_class.new(engine_schematic) }

	context "an engine schematic with only one number" do
	 	let(:engine_schematic) {
	 		<<~ENGINE_SCHEMATIC
	 			1*
	 		ENGINE_SCHEMATIC
	 	}

	 	it "finds the part number" do
	 		expect(engine_schematic_parser.part_numbers).to eq([1])
	 	end
	end

	context "an engine schematic with two part numbers" do
	 	let(:engine_schematic) {
	 		<<~ENGINE_SCHEMATIC
	 			123*2
	 		ENGINE_SCHEMATIC
	 	}

	 	it "can find the coordinates of each symbol" do
	 		expect(engine_schematic_parser.symbols.size).to eq(1)
	 		expect(engine_schematic_parser.symbols.first.xpos).to eq(3)
	 		expect(engine_schematic_parser.symbols.first.ypos).to eq(0)
	 	end

	 	it "can find the coordinates of each number" do
	 		n = engine_schematic_parser.numbers
	 		expect(n.size).to eq(2)
	 		expect(n[0].number).to eq(123)
	 		expect(n[0].xpos).to eq(0)
	 		expect(n[0].xmin).to eq(0)
	 		expect(n[0].xmax).to eq(2)
	 		expect(n[0].ypos).to eq(0)
	 		expect(n[1].number).to eq(2)
	 		expect(n[1].xpos).to eq(4)
	 		expect(n[1].xmin).to eq(4)
	 		expect(n[1].xmax).to eq(4)
	 		expect(n[1].ypos).to eq(0)
	 	end

	 	it "finds both part numbers" do
	 		expect(engine_schematic_parser.part_numbers).to eq([123, 2])
	 	end
	end

	context "an engine schematic where one number touches a symbol and the other does not" do
	 	let(:engine_schematic) {
	 		<<~ENGINE_SCHEMATIC
	 			123*.2
	 		ENGINE_SCHEMATIC
	 	}

	 	it "finds only the part number touching the symbol" do
	 		expect(engine_schematic_parser.part_numbers).to eq([123])
	 	end
	end

	context "an engine schematic where a number touches a symbol vertically" do
	 	let(:engine_schematic) {
	 		<<~ENGINE_SCHEMATIC
	 			123
	 			*..
	 			..5
	 		ENGINE_SCHEMATIC
	 	}

	 	it "finds only the part number touching the symbol" do
	 		expect(engine_schematic_parser.part_numbers).to eq([123])
	 	end
	end

	context "an engine schematic where a number touches a symbol diagonally" do
	 	let(:engine_schematic) {
	 		<<~ENGINE_SCHEMATIC
	 			23.
	 			..*
	 			.4.
	 			.5.
	 		ENGINE_SCHEMATIC
	 	}

	 	it "finds only the part number touching the symbol" do
	 		expect(engine_schematic_parser.part_numbers).to eq([23,4])
	 	end

	 	it "finds the sum of part numbers" do
	 		expect(engine_schematic_parser.sum_of_part_numbers).to eq(27)
	 	end
	end

	context "the example schematic" do
		let(:engine_schematic) {
			<<~ENGINE_SCHEMATIC
				467..114..
				...*......
				..35..633.
				......#...
				617*......
				.....+.58.
				..592.....
				......755.
				...$.*....
				.664.598..		
			ENGINE_SCHEMATIC
		}

		it "finds the sum of part numbers" do
			expect(engine_schematic_parser.sum_of_part_numbers).to eq(4361)
		end

		# The missing part wasn't the only issue - one of the gears in the engine is
		# wrong. A gear is any * symbol that is adjacent to exactly two part
		# numbers. Its gear ratio is the result of multiplying those two numbers
		# together.

		it "finds the gears" do
			gears = engine_schematic_parser.gears

			expect(gears.size).to eq(2)
			expect(gears[0].xpos).to eq(3)
			expect(gears[0].ypos).to eq(1)

			expect(gears[1].xpos).to eq(5)
			expect(gears[1].ypos).to eq(8)
		end

		it "finds the gear ratio" do
			gear_ratio_of_gears = engine_schematic_parser.gear_ratio_of_gears

			expect(gear_ratio_of_gears).to eq([467*35, 755*598])
		end

		it "finds the sum of gear ratios ratio" do
			expect(engine_schematic_parser.sum_of_gear_ratio).to eq(467835)
		end

	end
end