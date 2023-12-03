class Round
	attr_reader :cubes_by_colour

	def initialize(round_text)
		@cubes_by_colour = round_text.split(", ").inject({}) do |memo, colour_def| 
			count, colour = colour_def.split(" ")
			memo.merge(colour => count.to_i)
		end
	end

	def cubes_of_colour(colour)
		@cubes_by_colour.fetch(colour, 0)
	end

	def possible?(assumed_bag_contents)
		@cubes_by_colour.all? do |colour, number_drawn|
			number_drawn <= assumed_bag_contents.fetch(colour, 0)
		end
	end
end

RSpec.describe Round do
	subject(:round) { described_class.new("3 blue, 4 red") }

	it "can say if the round is possible for a given configuration" do
		expect(round.possible?("blue" => 2, "red" => 4)).to eq(false)
		expect(round.possible?("blue" => 3, "red" => 4)).to eq(true)
		expect(round.possible?("blue" => 4, "red" => 4)).to eq(true)
		expect(round.possible?("green" => 1)).to eq(false)
	end
end

class Game
	attr_reader :input_line

	def initialize(input_line)
		@input_line = input_line
		parse!
	end

	def id
		@game_id
	end

	def number_of_rounds
		@rounds.size
	end

	def number_of_cubes(round:, colour:)
		@rounds[round - 1].cubes_of_colour(colour)
	end

	def is_this_game_possible?(assumed_bag_contents)
		@rounds.all? { |round| round.possible?(assumed_bag_contents) }
	end

private
	def parse!
		game_def, rounds = input_line.split(":")
		@game_id = game_def.split(" ").last.to_i
		@rounds = rounds.split(";").map {|r| Round.new(r) }
	end
end

RSpec.describe Game do
	subject(:game) { described_class.new("Game 1: 3 blue, 4 red; 1 red, 2 green, 6 blue; 2 green") }
	
	it "can parse a game" do
		expect(game.id).to eq(1)
		expect(game.number_of_rounds).to eq(3)
		expect(game.number_of_cubes(round: 1, colour: "blue")).to eq(3)
		expect(game.number_of_cubes(round: 1, colour: "red")).to eq(4)
		expect(game.number_of_cubes(round: 2, colour: "red")).to eq(1)
		expect(game.number_of_cubes(round: 2, colour: "green")).to eq(2)
		expect(game.number_of_cubes(round: 2, colour: "blue")).to eq(6)
		expect(game.number_of_cubes(round: 3, colour: "green")).to eq(2)
	end

	it "can determine if the game is possible for a given configuration" do
		expect(game.is_this_game_possible?("blue" => 6, "red" => 4, "green" => 2)).to eq(true)
		expect(game.is_this_game_possible?("blue" => 5, "red" => 4, "green" => 2)).to eq(false)
		expect(game.is_this_game_possible?("blue" => 6, "red" => 3, "green" => 2)).to eq(false)
		expect(game.is_this_game_possible?("blue" => 6, "red" => 4, "green" => 1)).to eq(false)
		expect(game.is_this_game_possible?("blue" => 6, "red" => 4, "green" => 2, "yellow" => 1)).to eq(true)
	end
end


class Day2
	def parse_game(input_line)
		Game.new(input_line)
	end

	def what_games_are_possible?(list_of_games, required_configuration)
		games = list_of_games.split("\n").reject {|g| g.empty? }.map {|l| Game.new(l) }

		games.select {|g| g.is_this_game_possible?(required_configuration)}.map {|g| g.id}
	end

	def sum_game_ids_of_possible_games(list_of_games, required_configuration)
		what_games_are_possible?(list_of_games, required_configuration).inject(&:+)
	end

end

RSpec.describe Day2 do

	subject(:day2) { Day2.new }

	context "given a list of two games" do
		let(:list_of_games) {
			<<~LIST_OF_GAMES
				Game 1: 3 blue, 4 red; 1 red, 2 green, 6 blue; 2 green
				Game 2: 1 blue, 2 green; 3 green, 4 blue, 1 red; 1 green, 1 blue
			LIST_OF_GAMES
		}

		it "can determine which games are possible given a particular assumed bag contents" do
			assumed_bag_contents = {
				"blue" => 5, 
				"red" => 4,
				"green" => 3
			}
			possible_games = day2.what_games_are_possible?(list_of_games, assumed_bag_contents)
			expect(possible_games).to eq([2])
		end
	end

	context "given a list of five games" do
		let(:list_of_games) {
			<<~LIST_OF_GAMES
				Game 1: 3 blue, 4 red; 1 red, 2 green, 6 blue; 2 green
				Game 2: 1 blue, 2 green; 3 green, 4 blue, 1 red; 1 green, 1 blue
				Game 3: 8 green, 6 blue, 20 red; 5 blue, 4 red, 13 green; 5 green, 1 red
				Game 4: 1 green, 3 red, 6 blue; 3 green, 6 red; 3 green, 15 blue, 14 red
				Game 5: 6 red, 1 blue, 3 green; 2 blue, 1 red, 2 green
			LIST_OF_GAMES
		}

		it "can determine which games are possible given a particular assumed bag contents" do
			assumed_bag_contents = {
				"red" => 12,
				"green" => 13,
				"blue" => 14 
			}
			possible_games = day2.what_games_are_possible?(list_of_games, assumed_bag_contents)
			expect(possible_games).to eq([1,2,5])
		end

		it "can sum the ids of possible games" do
			assumed_bag_contents = {
				"red" => 12,
				"green" => 13,
				"blue" => 14 
			}
			sum_of_ids =day2.sum_game_ids_of_possible_games(list_of_games, assumed_bag_contents)

			expect(sum_of_ids).to eq(8)
		end

	end
end