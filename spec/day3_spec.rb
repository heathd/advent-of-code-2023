require "strscan"

class EngineToken
	attr_reader :xmin, :xmax, :y

	# count from zero
	# minimum x is left
	# minimum y is up
	def initialize(xmin, xmax, y)
		@xmin = xmin
		@xmax = xmax
		@y = y
	end

	def touches?(other_token)
		x_extent = Range.new(xmin - 1, xmax + 1)
		y_extent = Range.new(y - 1, y + 1)
		(x_extent.cover?(other_token.xmin) || x_extent.cover?(other_token.xmax)) &&
			(y_extent.cover?(other_token.y) || y_extent.cover?(other_token.y))
	end
end

class EngineSymbol < EngineToken
	attr_reader :char, :xpos, :ypos

	def initialize(char, xpos, ypos)
		@char = char
		@xpos = xpos
		@ypos = ypos
		super(xpos, xpos, ypos)
	end
end

class EngineNumber < EngineToken
	attr_reader :number, :xpos, :ypos

	def initialize(number, xpos, ypos)
		@number = number
		@xpos = xpos
		@ypos = ypos
		super(xpos, xpos + number.to_s.size - 1, ypos)
	end

end

class EngineSchematicParser
	attr_reader :engine_schematic

	def initialize(engine_schematic)
		@engine_schematic = engine_schematic
	end

	def symbols
		symbols = []

		engine_schematic.split("\n").each.with_index do |line, ypos|
			line.each_char.with_index do |char, xpos|
				if is_symbol?(char)
					symbols << EngineSymbol.new(char, xpos, ypos)
				end
			end
		end

		symbols
	end

	def numbers
		numbers = []

		engine_schematic.split("\n").each.with_index do |line, ypos|
			s = StringScanner.new(line)
			while s.scan_until(/[0-9]+/)
				numbers << EngineNumber.new(s.matched.to_i, s.charpos - s.matched.size, ypos)
			end
		end

		numbers
	end

	def is_symbol?(char)
		!(char =~ /^[0-9\.]$/)
	end

	def part_numbers
		numbers.select {|n| symbols.any? {|s| s.touches?(n)}}.map {|n| n.number}
	end

	def sum_of_part_numbers
		part_numbers.inject(&:+)
	end
end

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
	end
end