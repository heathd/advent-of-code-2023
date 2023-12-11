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

class Game
  attr_reader :input_line, :rounds

  def initialize(input_line)
    @input_line = input_line
    parse!
  end

  def id
    @game_id
  end

  def number_of_rounds
    rounds.size
  end

  def number_of_cubes(round:, colour:)
    rounds[round - 1].cubes_of_colour(colour)
  end

  def is_this_game_possible?(assumed_bag_contents)
    rounds.all? { |round| round.possible?(assumed_bag_contents) }
  end

  def fewest_cubes_possible
    minset = {}
    rounds.each do |round|
      round.cubes_by_colour.each do |colour, count|
        minset[colour] = [minset.fetch(colour, 0), count].max
      end
    end
    minset
  end

  def power_of_minset
    fewest_cubes_possible.inject(1) {|memo, (colour, count)| 
      memo * count
    }
  end

private
  def parse!
    game_def, rounds = input_line.split(":")
    @game_id = game_def.split(" ").last.to_i
    @rounds = rounds.split(";").map {|r| Round.new(r) }
  end
end

class Day2
  def parse_game(input_line)
    Game.new(input_line)
  end

  def parse_games(list_of_games)
    list_of_games.split("\n").reject {|g| g.empty? }.map {|l| Game.new(l) }
  end

  def what_games_are_possible?(list_of_games, required_configuration)
    parse_games(list_of_games).select {|g| g.is_this_game_possible?(required_configuration)}.map {|g| g.id}
  end

  def sum_game_ids_of_possible_games(list_of_games, required_configuration)
    what_games_are_possible?(list_of_games, required_configuration).inject(&:+)
  end

  def power_of_minsets(list_of_games)
    parse_games(list_of_games).inject(0) {|memo, game| game.power_of_minset + memo}
  end
end

if __FILE__==$0
  assumed_bag_contents = {
    "red" => 12,
    "green" => 13,
    "blue" => 14 
  }

  puts Day2.new.power_of_minsets(ARGF.read)
end
