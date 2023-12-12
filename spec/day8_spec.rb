require 'day8'

RSpec.describe Navigator do
  it "can parse instructions" do
    expect(Navigator.new("RL").instructions).to eq("RL")
    expect(Navigator.new("R").instructions).to eq("R")
  end

  it "rejects illegal instructions" do
    expect {Navigator.new(" ").instructions}.to raise_error("Illegal instruction")
  end

  it "can parse nodes" do
    expect(Navigator.new("RL\n\nAAA = (BBB, CCC)\n").nodes).to eq({"AAA" => ["BBB", "CCC"]})
  end

  context "the example given in the exercise description" do
    subject(:navigator) {described_class.new(input)}
    
    let(:input) {
      <<~MAP
      RL

      AAA = (BBB, CCC)
      BBB = (DDD, EEE)
      CCC = (ZZZ, GGG)
      DDD = (DDD, DDD)
      EEE = (EEE, EEE)
      GGG = (GGG, GGG)
      ZZZ = (ZZZ, ZZZ)
      MAP
    }

    it "can follow instructions until it reaches ZZZ" do
      expect(navigator.path_to_zzz).to eq(%w{
        CCC
        ZZZ
      })
    end
  end

  context "a second example" do
    subject(:navigator) {described_class.new(input)}
    
    let(:input) {
      <<~MAP
      LLR

      AAA = (BBB, BBB)
      BBB = (AAA, ZZZ)
      ZZZ = (ZZZ, ZZZ)
      MAP
    }

    it "can follow instructions until it reaches ZZZ" do
      expect(navigator.path_to_zzz).to eq(%w{
        BBB
        AAA
        BBB
        AAA
        BBB
        ZZZ
      })
    end

  end

end

RSpec.describe SequenceFromStartNode do
  subject(:seq) {described_class.new(start_node, navigator)}
  subject(:navigator) {Navigator.new(input)}
    
  let(:input) {
    <<~MAP
      LR

      11A = (11B, XXX)
      11B = (XXX, 11Z)
      11Z = (11B, XXX)
      22A = (22B, XXX)
      22B = (22C, 22C)
      22C = (22Z, 22Z)
      22Z = (22B, 22B)
      XXX = (XXX, XXX)
    MAP
  }

  context "starting at 11A" do
    let(:start_node) {"11A"}

    it "position starts at zero" do
      expect(seq.pos).to eq(0)
    end

    it "describes the path to a node ending Z" do
      expect(seq.path_to_z).to eq(%w{
        11B
        11Z
      })
    end

    it "advances pos to 2 after consuming two elements of a sequence" do
      seq.path_to_z
      expect(seq.pos).to eq(2)
    end

    it "advances to the next Z when called a second time" do
      seq.path_to_z
      expect(seq.path_to_z).to eq(%w{
        11B
        11Z
      })
      expect(seq.pos).to eq(4)
    end
  end

  context "starting at 11A" do
    let(:start_node) {"22A"}

    it "describes the path to a node ending Z" do
      expect(seq.path_to_z).to eq(%w{
        22B
        22C
        22Z
      })
    end

    it "advances pos to 3" do
      seq.path_to_z
      expect(seq.pos).to eq(3)
    end

    it "advances to the next Z when called a second time" do
      seq.path_to_z
      expect(seq.path_to_z).to eq(%w{
        22B
        22C
        22Z
      })
      expect(seq.pos).to eq(6)
    end
  end

end

RSpec.describe GhostNavigator do
  subject(:navigator) {described_class.new(input)}
  
  let(:input) {
    <<~MAP
      LR

      11A = (11B, XXX)
      11B = (XXX, 11Z)
      11Z = (11B, XXX)
      22A = (22B, XXX)
      22B = (22C, 22C)
      22C = (22Z, 22Z)
      22Z = (22B, 22B)
      XXX = (XXX, XXX)
    MAP
  }

  it "can find the path to a node ending z" do
    expect(navigator.steps_to_all_be_at_z).to eq(6)
  end

end