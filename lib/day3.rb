require "strscan"

class EngineToken
  attr_reader :xmin, :xmax, :y

  # count from zero
  # minimum x is left
  # minimum y is up
  def initialize(xmin, xmax, y)
    @xmin = xmin
    @xmax = xmax
    @y = y
  end

  def touches?(other_token)
    x_extent = Range.new(xmin - 1, xmax + 1)
    y_extent = Range.new(y - 1, y + 1)
    (x_extent.cover?(other_token.xmin) || x_extent.cover?(other_token.xmax)) &&
      (y_extent.cover?(other_token.y) || y_extent.cover?(other_token.y))
  end
end

class EngineSymbol < EngineToken
  attr_reader :char, :xpos, :ypos

  def initialize(char, xpos, ypos)
    @char = char
    @xpos = xpos
    @ypos = ypos
    super(xpos, xpos, ypos)
  end
end

class EngineNumber < EngineToken
  attr_reader :number, :xpos, :ypos

  def initialize(number, xpos, ypos)
    @number = number
    @xpos = xpos
    @ypos = ypos
    super(xpos, xpos + number.to_s.size - 1, ypos)
  end

end

class EngineSchematicParser
  attr_reader :engine_schematic

  def initialize(engine_schematic)
    @engine_schematic = engine_schematic
  end

  def symbols
    symbols = []

    engine_schematic.split("\n").each.with_index do |line, ypos|
      line.each_char.with_index do |char, xpos|
        if is_symbol?(char)
          symbols << EngineSymbol.new(char, xpos, ypos)
        end
      end
    end

    symbols
  end

  def numbers
    numbers = []

    engine_schematic.split("\n").each.with_index do |line, ypos|
      s = StringScanner.new(line)
      while s.scan_until(/[0-9]+/)
        numbers << EngineNumber.new(s.matched.to_i, s.charpos - s.matched.size, ypos)
      end
    end

    numbers
  end

  def is_symbol?(char)
    !(char =~ /^[0-9\.]$/)
  end

  def part_numbers
    numbers.select {|n| symbols.any? {|s| s.touches?(n)}}.map {|n| n.number}
  end

  def sum_of_part_numbers
    part_numbers.inject(&:+)
  end

  def gears
    symbols.select {|s| s.char == "*"}.select do |s|
      numbers.select {|n| n.touches?(s)}.size == 2
    end
  end

  def gear_ratio_of_gears
    stars_with_adjacent_numbers = symbols.select {|s| s.char == "*"}.map do |s|
      numbers.select {|n| n.touches?(s)}
    end

    stars_with_adjacent_numbers
      .select {|num_list| num_list.size == 2}
      .map {|num_list| num_list[0].number * num_list[1].number }
  end

  def sum_of_gear_ratio
    gear_ratio_of_gears.inject(&:+)
  end
end

if __FILE__==$0
  puts EngineSchematicParser.new(ARGF.read).sum_of_part_numbers
end
