class Navigator
  attr_reader :input, :lines

  def initialize(input)
    @input = input
    @lines = input.split("\n")
  end

  def instructions
    instructions = lines.first
    raise "Illegal instruction" unless valid_instructions?(instructions)
    instructions
  end

  def valid_instructions?(i)
    i.chars.all? {|c| %w{L R}.include?(c)}
  end

  def instructions_enumerator
    Enumerator.new do |enum|
      i = 0
      while true
        enum.yield(instructions[i % instructions.size])
        i += 1
      end
    end
  end

  def nodes
    @nodes ||= begin
      as_array = lines[2..-1].map do |line|
        line =~ /^([^ ]+) = \(([^ ]+), ([^ ]+)\)/
        [$1, [$2, $3]]
      end
      Hash[as_array]
    end
  end

  def path_to_zzz
    i = instructions_enumerator
    path = []

    current = "AAA"
    while current != "ZZZ"
      instruction = i.next
      current = if instruction == "R"
        nodes[current][1]
      elsif instruction == "L"
        nodes[current][0]
      else
        raise "Illegal instruction '#{instruction}'"
      end
      path << current
    end
    path
  end
end

if __FILE__==$0
  puts Navigator.new(ARGF.read).path_to_zzz.size
end
