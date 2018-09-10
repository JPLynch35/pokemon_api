require 'json'

class Move
  attr_reader :pp, :type, :accuracy, :power
  def initialize(name, pp, type, accuracy, move_type = "attack")
    @name = name
    @pp = pp
    @type = type
    @accuracy = accuracy
    @move_type = move_type
  end

  def attack_move(args)
    @power = args["power"]
  end

  def status_move(args)
  end

  def self.from_data(move_name)
    raw_json = File.read('./data/moves.json')
    data = JSON.parse(raw_json)
    data = data[move_name]
    move = Move.new(move_name, data["pp"], data["type"], data["accuracy"])
    data["actions"].each_keys do |action|
      move.send(action.to_sym, data["action"][action])
    end
    move
  end
end
