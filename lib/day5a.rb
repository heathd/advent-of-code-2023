$LOAD_PATH << File.dirname(__FILE__)

require 'day5'

puts Mapper.new(ARGF.read).lowest_mapping_for_seeds_as_ranges
