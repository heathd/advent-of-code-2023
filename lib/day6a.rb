$LOAD_PATH << File.dirname(__FILE__) + "/."
require 'day6/boat_race'

race = BoatRace.new(race_duration: 44899691, best_distance: 277113618901768)

puts "Answer for part 2: #{race.number_of_winning_button_press_durations}"