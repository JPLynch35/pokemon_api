require 'json'
require './lib/stat_values'
require './lib/move'

class Pokemon
  #attr_reader for calculating crits
  attr_reader :speed_values, :type_1, :type_2, :level, :name, :move_one, :move_two, :move_three, :move_four
  attr_accessor :current_hp

  def initialize(name, level, hp_values, attack_values, defense_values, special_values, speed_values, move_one, move_two, move_three, move_four, type_1, type_2 = nil)
    @name = name
    @level = level
    @hp_values = hp_values
    @attack_values = attack_values
    @defense_values = defense_values
    @special_values = special_values
    @speed_values = speed_values
    @type_1 = type_1
    @type_2 = type_2
    @current_hp = hp
    # @move_one = Move.from_data(move_one)
    # @move_two = Move.from_data(move_two)
    # @move_three = Move.from_data(move_three)
    # @move_four = Move.from_data(move_four)
    @move_one = move_one
    @move_two = move_two
    @move_three = move_three
    @move_four = move_four
  end

  def self.from_data(species_name, user_input)
    raw_json = File.read('./data/pokemon.json')
    pokemon_list = JSON.parse(raw_json)
    base_values = pokemon_list[species_name]
    hp_values = StatValues.new(user_input["hp_iv"], user_input["hp_ev"], base_values["base_hp"])
    attack_values = StatValues.new(user_input["attack_iv"], user_input["attack_ev"], base_values["base_attack"])
    defense_values = StatValues.new(user_input["defense_iv"], user_input["defense_ev"], base_values["base_defense"])
    special_values = StatValues.new(user_input["special_iv"], user_input["special_ev"], base_values["base_special"])
    speed_values = StatValues.new(user_input["speed_iv"], user_input["speed_ev"], base_values["base_speed"])
    type_1 = base_values["type_1"].to_sym
    type_2 = base_values["type_2"].to_sym unless base_values["type_2"].nil?
    move_one = user_input["move_one"]
    move_two = user_input["move_two"]
    move_three = user_input["move_three"]
    move_four = user_input["move_four"]
    pokemon = Pokemon.new(species_name, user_input["level"], hp_values, attack_values, defense_values, special_values, speed_values, move_one, move_two, move_three, move_four, type_1, type_2)
    pokemon.current_hp = user_input["current_hp"] unless user_input["current_hp"].nil?
    pokemon
  end

  def hp
    health = @hp_values.base + @hp_values.iv
    health *= 2
    health += ((Math.sqrt(@hp_values.ev))/4)
    health *= @level
    health /= 100
    health += @level
    health += 10
    health.to_i
  end

  def stat_calculation(values)
    stat = values.base + values.iv
    stat *= 2
    stat += Math.sqrt(values.ev) / 4
    stat *= @level
    stat /= 100
    stat += 5
    stat.to_i
  end

  def attack
    stat_calculation(@attack_values)
  end

  def defense
    stat_calculation(@defense_values)
  end

  def special
    stat_calculation(@special_values)
  end

  def speed
    stat_calculation(@speed_values)
  end

  def to_h
    {hp: hp, current_hp: @current_hp}
  end
end
