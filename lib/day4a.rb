$LOAD_PATH << File.dirname(__FILE__)

require 'day4'

  puts ScratchCardScorer.new(ARGF.read).number_of_winning_scratchcards
