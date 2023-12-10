require 'day5'

RSpec.describe Mapper do
	let(:example) { <<~EXAMPLE
		seeds: 79 14 55 13

		seed-to-soil map:
		50 98 2
		52 50 48

		soil-to-fertilizer map:
		0 15 37
		37 52 2
		39 0 15

		fertilizer-to-water map:
		49 53 8
		0 11 42
		42 0 7
		57 7 4

		water-to-light map:
		88 18 7
		18 25 70

		light-to-temperature map:
		45 77 23
		81 45 19
		68 64 13

		temperature-to-humidity map:
		0 69 1
		1 0 69

		humidity-to-location map:
		60 56 37
		56 93 4
		EXAMPLE
	}

	subject(:mapper) { described_class.new(example) }

	it "parses the seeds" do
		expect(mapper.seeds).to eq([79,14,55,13])
	end

	describe "interaction with MapBuilder" do
		let(:map_builder) { instance_double(MapBuilder, parse: nil) }
		subject(:mapper) { described_class.new(example, map_builder: map_builder) }

		it "parses the maps" do
			mapper

			expect(map_builder).to have_received(:parse).with <<~DATA
				seed-to-soil map:
				50 98 2
				52 50 48
			DATA

			expect(map_builder).to have_received(:parse).with <<~DATA
				soil-to-fertilizer map:
				0 15 37
				37 52 2
				39 0 15
			DATA

			expect(map_builder).to have_received(:parse).with <<~DATA
				fertilizer-to-water map:
				49 53 8
				0 11 42
				42 0 7
				57 7 4
			DATA

			expect(map_builder).to have_received(:parse).with <<~DATA
				water-to-light map:
				88 18 7
				18 25 70
			DATA

			expect(map_builder).to have_received(:parse).with <<~DATA
				light-to-temperature map:
				45 77 23
				81 45 19
				68 64 13
			DATA

			expect(map_builder).to have_received(:parse).with <<~DATA
				temperature-to-humidity map:
				0 69 1
				1 0 69
			DATA

			expect(map_builder).to have_received(:parse).with <<~DATA
				humidity-to-location map:
				60 56 37
				56 93 4
			DATA
		end
	end

	describe "#map" do
		it "maps a specific from/to type and number" do
			expect(mapper.map(:light, 77)).to eq([:temperature, 45])
			expect(mapper.map(:soil, 15)).to eq([:fertilizer, 0])
		end

		it "maps to the destination type with the same value if there's no mapping" do
			expect(mapper.map(:soil, 77)).to eq([:fertilizer, 77])
		end

		it "maps to nil if the mapping is out of range for the type" do
			expect(mapper.map(:light, 44)).to eq([:temperature, 44])
		end

		it "maps the whole chain for the first example" do
			expect(mapper.map(:seed, 79)).to eq([:soil, 81])
			expect(mapper.map(:soil, 81)).to eq([:fertilizer, 81])
			expect(mapper.map(:fertilizer, 81)).to eq([:water, 81])
			expect(mapper.map(:water, 81)).to eq([:light, 74])
			expect(mapper.map(:light, 74)).to eq([:temperature, 78])
			expect(mapper.map(:temperature, 78)).to eq([:humidity, 78])
			expect(mapper.map(:humidity, 78)).to eq([:location, 82])
			# :location, 82
		end
	end

	describe "#ultimate_mapping" do
		it "maps 79 ultimately to 82" do
			expect(mapper.ultimate_mapping(79)).to eq(82)
		end
	end

	describe "mapping for seeds" do
		context "treating seeds as distinct values" do
			it "finds all the mappings" do
				expect(mapper.mappings_for_seeds).to eq([82, 43, 86, 35])
			end

			it "finds the lowest mapping" do
				expect(mapper.lowest_mapping_for_seeds).to eq(35)
			end
		end

		context "treating the seeds as range definitions" do
			let(:expected) {
				[(79...79+14).to_a,(55...55+13).to_a].flatten.map {|n| mapper.ultimate_mapping(n)}
			}

			it "finds all the mappings" do
				expect(mapper.mappings_for_seeds_as_ranges).to eq(expected)
			end

			it "finds the lowest mapping" do
				expect(mapper.lowest_mapping_for_seeds_as_ranges).to eq(expected.min)
			end
		end
	end
end

RSpec.describe MapForType do
	subject(:map_for_type) { MapForType.new(:seed, :soil) }

	context "a single mapping" do
		before(:each) {
			map_for_type.add_mapping!(50, 98, 3)
		}

		it "maps numbers before the range to the same number in the destination range" do
			expect(map_for_type.map(:seed, 97)).to eq([:soil, 97])
		end

		it "maps the number at the start of the range" do
			expect(map_for_type.map(:seed, 98)).to eq([:soil, 50])
		end

		it "maps the number at the end of the range" do
			expect(map_for_type.map(:seed, 100)).to eq([:soil, 52])
		end

		it "maps the number just after the end of the range to the same number in the destination range" do
			expect(map_for_type.map(:seed, 101)).to eq([:soil, 101])
		end

		it "returns nil for a type not mapped" do
			expect(map_for_type.map(:land, 101)).to eq(nil)
		end
	end
end

RSpec.describe MapBuilder do
	subject(:map_builder) { MapBuilder.new }

	let(:data) {
		<<~DATA
		seed-to-soil map:
		50 98 2
		52 50 48
		DATA
	}

	it "parses the data" do
		expected = MapForType.new(:seed, :soil)
		expected.add_mapping!(50, 98, 2)
		expected.add_mapping!(52, 50, 48)
		expect(map_builder.parse(data)).to eq(expected)
	end
end