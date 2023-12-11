require 'day6/boat_race'

RSpec.describe "Boat Races" do
  it "can be instantiated" do
    b = BoatRace.new(race_duration: 7, best_distance: 9)
    expect(b.race_duration).to eq(7)
    expect(b.best_distance).to eq(9)
  end

  it "can describe how far you'll travel for a given length of button press" do
    expect(BoatRace.distance_for(button_press_duration: 1, time: 10)).to eq(10)
  end

  context "7ms boat race with winning distance 9mm" do
    subject(:boat_race) { BoatRace.new(race_duration: 7, best_distance: 9) }

    it "can find the shortest winning button press" do
      expect(boat_race.shortest_button_press_that_wins).to eq(2)
    end

    it "can find the longest winning button press" do
      expect(boat_race.longest_button_press_that_wins).to eq(5)
    end

    it "can find the number of possible winning button press durations" do
      expect(boat_race.number_of_winning_button_press_durations).to eq(4)
    end
  end
end