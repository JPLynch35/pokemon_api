require 'json'
require './lib/stat_values'
require './lib/move'

class Pokemon
  #attr_reader for calculating crits
  attr_reader :speed_values, :type_1, :type_2, :level, :name, :move_one, :move_two, :move_three, :move_four
  attr_accessor :current_hp, :status_conditions

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
    @move_one = move_one
    @move_two = move_two
    @move_three = move_three
    @move_four = move_four
    @status_conditions = []
  end

  def self.from_data(pokemon_base, current_values = nil)
    raw_json = File.read('./data/pokemon.json')
    pokemon_list = JSON.parse(raw_json)
    base_values = pokemon_list[pokemon_base.species_name]
    hp_values = StatValues.new(pokemon_base.hp_iv, pokemon_base.hp_ev, base_values["base_hp"])
    attack_values = StatValues.new(pokemon_base.attack_iv, pokemon_base.attack_ev, base_values["base_attack"])
    defense_values = StatValues.new(pokemon_base.defense_iv, pokemon_base.defense_ev, base_values["base_defense"])
    special_values = StatValues.new(pokemon_base.special_iv, pokemon_base.special_ev, base_values["base_special"])
    speed_values = StatValues.new(pokemon_base.speed_iv, pokemon_base.speed_ev, base_values["base_speed"])
    type_1 = base_values["type_1"].to_sym
    type_2 = base_values["type_2"].to_sym unless base_values["type_2"].nil?
    move_one = Move.from_data(pokemon_base.move_one)
    move_two = Move.from_data(pokemon_base.move_two)
    move_three = Move.from_data(pokemon_base.move_three)
    move_four = Move.from_data(pokemon_base.move_four)
    pokemon = Pokemon.new(pokemon_base.species_name, pokemon_base.level, hp_values, attack_values, defense_values, special_values, speed_values, move_one, move_two, move_three, move_four, type_1, type_2)
    if current_values
      pokemon.current_hp = current_values["current_hp"]
      pokemon.move_one.current_pp = current_values["move_one"]["current_pp"]
      pokemon.move_two.current_pp = current_values["move_two"]["current_pp"]
      pokemon.move_three.current_pp = current_values["move_three"]["current_pp"]
      pokemon.move_four.current_pp = current_values["move_four"]["current_pp"]
      pokemon.status_conditions = current_values["status_conditions"]
    end
    pokemon
  end

  def to_h
    {
      name: @name,
      level: @level,
      hp: hp,
      current_hp: @current_hp,
      hp_percentage: hp_percentage,
      attack: attack,
      defense: defense,
      special: special,
      speed: speed,
      move_one: @move_one.to_h,
      move_two: @move_two.to_h,
      move_three: @move_three.to_h,
      move_four: @move_four.to_h,
      status_conditions: @status_conditions
    }
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

  def hp_percentage
    (current_hp.to_f/hp.to_f) * 100
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
    return (stat_calculation(@attack_values) / 2) if @status_conditions.include?("burn")
    stat_calculation(@attack_values)
  end

  def defense
    stat_calculation(@defense_values)
  end

  def special
    stat_calculation(@special_values)
  end

  def speed
    return (stat_calculation(@speed_values) * 0.75) if @status_conditions.include?("paralyze")
    stat_calculation(@speed_values)
  end

  def dead?
    @current_hp <= 0
  end

  def damage(damage_hp)
    @current_hp -= damage_hp
    @current_hp = 0 if @current_hp < 0
  end

  def move_by_name(name)
    [@move_one, @move_two, @move_three, @move_four].each do |move|
      return move if move.name == name
    end
    false
  end
end
