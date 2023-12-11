$LOAD_PATH << File.dirname(__FILE__) + "/."
require 'day6/boat_race'

races = [
  BoatRace.new(race_duration: 44, best_distance: 277),
  BoatRace.new(race_duration: 89, best_distance: 1136),
  BoatRace.new(race_duration: 96, best_distance: 1890),
  BoatRace.new(race_duration: 91, best_distance: 1768)
]

puts "Answer for part 1: #{races.map(&:number_of_winning_button_press_durations).inject(1, &:*)}"