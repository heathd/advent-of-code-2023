require 'prime'
require 'logger'

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
    path_to(start_node: "AAA", pred: lambda {|n| n == 'ZZZ'})
  end

  def path_to(start_node:, pred: )
    i = 0
    path = []

    current = start_node
    while !pred.call(current)
      instruction = instructions[i % instructions.size]
      i+=1
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

  def path_to_node_ending_z(start_node)
    path_to(start_node: start_node, pred: lambda {|n| n[-1]=="Z"})
  end
end

class SequenceFromStartNode
  attr_reader :start_node, :navigator, :path_since_start
  attr_accessor :pos

  def initialize(start_node, navigator)
    @start_node = start_node
    @current_node = start_node
    @navigator = navigator
    @pos = 0
    @path_since_start = []
  end

  def path_to_z
    path = navigator.path_to_node_ending_z(start_node)
    @path_since_start += path
    @current_node = path.last
    @pos += path.size
    path
  end
end

class GhostNavigator
  attr_reader :navigator, :logger

  def initialize(input, logger: Logger.new(nil))
    @navigator = Navigator.new(input)
    @logger = logger
  end

  def starting_points
    navigator.nodes.keys.select {|k| k[-1] == "A"}
  end

  def navigators
    @navigators ||= starting_points.map {|s| SequenceFromStartNode.new(s, navigator) }
  end

  def steps_to_all_be_at_z
    logger.info "Finding cycle lengths..."
    cycle_lengths = navigators.map.with_index do |n, i| 
      size = n.path_to_z.size
      logger.info "#{i}: #{size}"
      size
    end

    prime_factors = cycle_lengths.map {|n| ::Prime.prime_division(n)}.flatten.uniq

    logger.info "Prime factors: #{prime_factors.join(', ')}"
    prime_factors.inject(1, &:*)
  end

  def all_at_same_position?(positions)
    positions.group_by {|p| p}.size == 1
  end
end

if __FILE__==$0
  logger = Logger.new($stdout)
  result = GhostNavigator.new(ARGF.read, logger: logger).steps_to_all_be_at_z
  logger.info "Result: #{result}"
end
