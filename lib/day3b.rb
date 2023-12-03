$LOAD_PATH << File.dirname(__FILE__)

require 'day3'

puts EngineSchematicParser.new(ARGF.read).sum_of_gear_ratio
