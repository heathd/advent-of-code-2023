require 'strscan'

class Mapper
	attr_reader :map_data, :map_builder

	def initialize(map_data, map_builder: MapBuilder.new)
		@map_data = map_data
		@map_builder = map_builder
		@maps = parse_maps
	end

	def seeds
		map_data.match(/seeds: (([0-9]+ )*[0-9]+)$/)
		$1.split(" ").map(&:to_i)
	end

	def seeds_as_ranges
		seeds.each_slice(2).map {|start, length| start...start+length}
	end

	def maps
		@maps ||= parse_maps
	end

	def parse_maps
		_, *maps = map_data.split("\n\n")
		maps.map {|m| map_builder.parse(m.strip + "\n") }.flatten
	end

	def map(from, num)
		maps.each do |m| 
			dest = m.map(from, num)
			return dest if dest != nil
		end

		nil
	end

	def mapping_path(seed)
		type = :seed
		num = seed

		path = [[type, num]]
		while mapped = map(type, num)
			path << mapped
			type,num = mapped
		end
		path
	end

	def ultimate_mapping(seed)
		mapping_path(seed).last.last
	end

	def mappings_for_seeds
		seeds.map { |seed| ultimate_mapping(seed) }
	end

	def lowest_mapping_for_seeds
		mappings_for_seeds.min
	end

	def mappings_for_seeds_as_ranges
		seeds_as_ranges.map do |seed_range| 
			seed_range.map do |seed| 
				ultimate_mapping(seed) 
			end
		end.flatten
	end

	def lowest_mapping_for_seeds_as_ranges
		mappings_for_seeds_as_ranges.min
	end
end

class MapBuilder
	def parse(map_data)
		scanner = StringScanner.new(map_data)
		scanner.scan_until(/(.*?)-to-(.*?) map:/)
		from_type, to_type = scanner.captures.map(&:to_sym)

		map_for_type = MapForType.new(from_type, to_type)

		while scanner.scan_until(/([0-9]+) ([0-9]+) ([0-9]+)/)
			d, s, l = scanner.captures.map(&:to_i)
			map_for_type.add_mapping!(d, s, l)
		end

		map_for_type
	end
end

class Map
	ATTRS = %I{from_type to_type destination_range_start source_range_start length}
	attr_reader *ATTRS

	include Comparable

	def initialize(from_type, to_type, destination_range_start, source_range_start, length)
		@from_type = from_type
		@to_type = to_type
		@destination_range_start = destination_range_start
		@source_range_start = source_range_start
		@length = length
	end

	def can_map?(from)
		 from == @from_type
	end

	def in_range?(num)
		num >= @source_range_start && num < @source_range_start + @length
	end

	def map(from, num)
		if can_map?(from) && in_range?(num)
			[@to_type, @destination_range_start + num - @source_range_start]
		else
			nil
		end
	end

	def <=>(other)
		self_data = ATTRS.map {|a| [a, self.send(a)]}
		other_data = ATTRS.map {|a| [a, other.send(a)]}
		self_data <=> other_data
	end
end

class MapForType
	ATTRS = %I{from_type to_type maps}
	attr_reader *ATTRS

	include Comparable

	def initialize(from_type, to_type)
		@from_type = from_type
		@to_type = to_type
		@maps = []
	end

	def add_mapping!(destination_range_start, source_range_start, length)
		@maps << Map.new(from_type, to_type, destination_range_start, source_range_start, length)
	end

	def can_map?(from)
		 from == @from_type
	end

	def in_range?(num)
		@maps.any? {|m| m.in_range?(num)}
	end

	def map(from, num)
		if can_map?(from)
			map = @maps.find { |m| m.in_range?(num) }
			if map
				map.map(from, num)
			else
				[@to_type, num]
			end
		else
			nil
		end
	end

	def <=>(other)
		self_data = ATTRS.map {|a| [a, self.send(a)]}
		other_data = ATTRS.map {|a| [a, other.send(a)]}
		self_data <=> other_data
	end
end


if __FILE__==$0
	puts Mapper.new(ARGF.read).lowest_mapping_for_seeds
end
