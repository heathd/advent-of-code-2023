class SequenceAnalyzer
  attr_reader :sequence

  def initialize(sequence)
    @sequence = sequence
  end

  def self.differential(seq)
    seq.each_cons(2).map {|a,b| b-a}
  end

  def differentials
    return @differentials if @differentials

    @differentials = []
    s = sequence

    begin
      s = self.class.differential(s)
      @differentials << s
    end while !s.all? {|n| n==0}

    @differentials
  end

  def extrapolate
    differentials.inject(sequence.last) do |memo, differential|
      memo + differential.last
    end
  end

  def extrapolate_backwards
    ([sequence] + differentials).reverse.inject(0) do |memo, differential|
      differential.first - memo
    end
  end

  def self.from_file(data)
    lines = data.split("\n").map(&:strip).reject(&:empty?)

    lines.map {|line| SequenceAnalyzer.new(line.split(" ").map(&:to_i))}
  end
end

if __FILE__==$0
  if ARGV[0] == "-b"
    puts SequenceAnalyzer.from_file($stdin.read).map(&:extrapolate_backwards).inject(&:+)
  else
    puts SequenceAnalyzer.from_file($stdin.read).map(&:extrapolate).inject(&:+)
  end
end
