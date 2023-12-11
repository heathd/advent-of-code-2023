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

	def map(from, num)
		maps.each do |m| 
			dest = m.map_range(from, num...num+1)
			if dest != nil
				dest_type, dest_num = dest
				return [dest_type, dest_num.first]
			end
		end

		nil
	end

	def map_range(from, range)
		maps.each do |m| 
			dest = m.map_range(from, range)
			return dest if dest != nil
		end

		nil
	end

	def mapping_path(seed_ranges)
		type = :seed

		path = [[type, seed_ranges]]
		dest_range = []
		dest_type = nil
		begin
			seed_ranges.map do |seed_range|
				mapped = map_range(type, seed_range)
				dest_type ||= mapped.first
				dest_range += mapped[1..-1]
			end
		end
	end

	def ultimate_mapping(seed)
		mapping_path([seed...seed+1]).last.last
	end

	def ultimate_mapping_for_range(seed_range)
		mapping_path([seed_range]).last.last
	end

	def mappings_for_seeds
		seeds.map { |seed| ultimate_mapping(seed) }
	end

	def lowest_mapping_for_seeds
		mappings_for_seeds.min
	end

	def mappings_for_seeds_as_ranges
		total = seeds_as_ranges.map {|r| r.size}.inject(&:+)

		bar = TTY::ProgressBar.new("calculating [:bar] [:percent] [:eta]", output: $stdout, total: total, frequency: 10)

		seeds_as_ranges.map do |seed_range| 
			seed_range.map do |seed| 
				bar.advance
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

	def xmap(from, num)
		if can_map?(from)
			map = @maps.find { |m| m[:source_range].cover?(num) }
			if map
				[@to_type, map_num(map, num)]
			else
				[@to_type, num]
			end
		else
			nil
		end
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
