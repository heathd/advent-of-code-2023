class BoatRace
  attr_reader :race_duration, :best_distance

  def initialize(race_duration:, best_distance:)
    @race_duration = race_duration
    @best_distance = best_distance
  end

  def self.distance_for(button_press_duration:, time:)
    button_press_duration * time
  end

  def distance_for_button_press(button_press_duration)
    boat_speed = button_press_duration
    boat_speed * (race_duration - button_press_duration)
  end

  def shortest_button_press_that_wins
    i = 1
    while distance_for_button_press(i) < best_distance
      i += 1
    end
    i
  end

  def longest_button_press_that_wins
    i = race_duration
    while distance_for_button_press(i) < best_distance
      i -= 1
    end
    i
  end

  def number_of_winning_button_press_durations
    (shortest_button_press_that_wins..longest_button_press_that_wins).size
  end
end
