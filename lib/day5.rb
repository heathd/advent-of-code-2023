require 'strscan'
require 'tty-progressbar'

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

	def mapper_for(type)
		maps.find {|m| m.can_map?(type)}
	end

	def can_map?(type)
		!mapper_for(type).nil?
	end

	def map(from, num_or_range)
		if num_or_range.is_a?(Range)
			map_range(from, num_or_range)
		else
			dest = map_range(from, num_or_range...num_or_range+1)
			dest && [dest.first, dest.last.first]
		end
	end

	def map_range(from, range)
		if can_map?(from)
			mapper_for(from).map_range(from, range)
		end
	end

	def mapping_path(type, seed_ranges)
		path = []
		dest_range = []
		dest_type = nil
		mapped = true
		i = 0

		while mapped && i<20
			i+=1

			path << [type, *seed_ranges]
			seed_ranges.map do |seed_range|
				mapped = map_range(type, seed_range)
				if mapped
					dest_type ||= mapped.first
					dest_range += mapped[1..-1]
				end
			end

			if dest_type
				type = dest_type
				seed_ranges = dest_range
				dest_type = nil
				dest_range = []
				mapped = true
			end
		end 

		path
	end

	def ultimate_mapping(seed)
		path = mapping_path(:seed, [seed...seed+1])
		type, *ranges = path.last
		ranges.last.first
	end

	def ultimate_mapping_for_range(seed_range)
		path = mapping_path(:seed, [seed_range])
		type, *ranges = path.last
		ranges
	end

	def mappings_for_seeds
		seeds.map { |seed| ultimate_mapping(seed) }
	end

	def lowest_mapping_for_seeds
		mappings_for_seeds.min
	end

	def mappings_for_seeds_as_ranges
		total = seeds_as_ranges.map {|r| r.size}.inject(&:+)

		path = mapping_path(:seed, seeds_as_ranges)
		type, *ranges = path.last
		ranges
	end

	def lowest_mapping_for_seeds_as_ranges
		mappings_for_seeds_as_ranges.map(&:first).min
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
		@maps << {
			destination_range_start: destination_range_start, 
			source_range: source_range_start...source_range_start+length
		}
		@maps.sort_by! {|m| m[:source_range].first}
	end

	def can_map?(from)
		 from == @from_type
	end

	def map_num(map, num)
		map[:destination_range_start] + num - map[:source_range].first
	end

	def earliest_source_range_start
		@maps.first[:source_range].first
	end

	def split_on_range_boundaries(range)
		ranges = []

		current_range_start = range.first
		map_iterator = @maps.each

		while current_range_start
			begin
				map = map_iterator.next

				if current_range_start < map[:source_range].first
					if range.last > map[:source_range].last
						ranges << Range.new(current_range_start, map[:source_range].first, true)
						ranges << Range.new(map[:source_range].first, map[:source_range].last, true)
						current_range_start = map[:source_range].last
					elsif range.last > map[:source_range].first
						ranges << Range.new(current_range_start, map[:source_range].first, true)
						ranges << Range.new(map[:source_range].first, range.last, true)
						current_range_start = nil
					else
						ranges << Range.new(current_range_start, range.last, true)
						current_range_start = nil
					end
				elsif current_range_start < map[:source_range].last
					if range.last <= map[:source_range].last
						ranges << Range.new(current_range_start, range.last, true)
						current_range_start = nil
					else
						ranges << Range.new(current_range_start, map[:source_range].last, true)
						current_range_start = map[:source_range].last
					end
				end
			rescue StopIteration
				ranges << Range.new(current_range_start, range.last, true)
				current_range_start = nil
			end
		end
		ranges
	end

	def map_range(from, range)
		return nil unless can_map?(from)
		source_ranges = split_on_range_boundaries(range)

		[@to_type] + source_ranges.map {|s| map_source_contiguous_range(s)}
	end

	def map_source_contiguous_range(source_range)
		map = @maps.find { |m| m[:source_range].cover?(source_range) }
		if map
			dest_start = map_num(map, source_range.first)
			if source_range.exclude_end?
				dest_range = dest_start...map_num(map, source_range.last - 1) + 1
			else
				raise "Can only process ranges which exclude end"
			end
			dest_range
		else
			source_range
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
