require 'json'
require 'pry'

class Move
  attr_reader :pp, :type, :accuracy, :power, :priority, :name, :actions
  attr_accessor :current_pp
  def initialize(name, pp, type, accuracy, actions)
    @name = name
    @pp = pp
    @current_pp = pp
    @type = type.to_sym
    @accuracy = accuracy
    @actions = actions
  end

  def self.from_data(move_name, current_pp = nil)
    raw_json = File.read('./data/moves.json')
    move_data = JSON.parse(raw_json)
    data = move_data[move_name]
    #My mission will be complete if I can remove the following line of code
    data = move_data["Pound"] if data.nil?
    move = Move.new(move_name, data["pp"], data["type"], data["accuracy"], data["actions"])
    move.current_pp = current_pp unless current_pp.nil?
    move
  end

  def to_h
    {
      name: @name,
      pp: @pp,
      current_pp: @current_pp,
      type: @type,
      accuracy: @accuracy
    }
  end
end
