$LOAD_PATH << File.dirname(__FILE__)

require 'day2'

puts Day2.new.power_of_minsets(ARGF.read)
