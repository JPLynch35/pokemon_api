require './lib/damage'
require './lib/status'

class MoveEffects
  attr_reader :events
  include Damage
  include Status
  def initialize(attacker, defender, move)
    @attacker = attacker
    @defender = defender
    @move = move
    @events = []
  end

  def run!
    @move.actions.each do |action|
      send(action.keys.first.to_sym, action.values.first)
    end
  end

  def attack(params)
    damage_value = damage(@attacker, @defender, params["power"], @move)
    @defender.active_pokemon.damage(damage_value)
    damage_percentage = (damage_value.to_f / @defender.active_pokemon.hp.to_f) * 100
    @events.push(@defender => {"damage" => damage_percentage})
  end

  def double_hit(params)
    damage_value = damage(@attacker, @defender, params["power"], @move)
    damage_percentage = (damage_value.to_f / @defender.active_pokemon.hp.to_f) * 100
    2.times do |i|
      unless @defender.active_pokemon.dead?
        @defender.active_pokemon.damage(damage_value)
        @events.push(@attacker => "multi_hit") if i > 0
        @events.push(@defender => {"damage" => damage_percentage})
      end
    end
  end

  def multi_hit(params)
    hit_count = 0
    count_seed = rand(200)
    hit_count = 2 if count_seed < 75
    hit_count = 3 if count_seed < 150 && count_seed >= 75
    hit_count = 4 if count_seed < 175 && count_seed >= 150
    hit_count = 5 if count_seed >= 175

    damage_value = damage(@attacker, @defender, params["power"], @move)
    damage_percentage = (damage_value.to_f / @defender.active_pokemon.hp.to_f) * 100

    hit_count.times do |i|
      unless @defender.active_pokemon.dead?
        @defender.active_pokemon.damage(damage_value)
        @events.push(@attacker => "multi_hit") if i > 0
        @events.push(@defender => {"damage" => damage_percentage})
      end
    end
  end

  def status(params)
    target = @attacker if params["target"] == "attacker"
    target = @defender if params["target"] == "defender"
    if @defender.active_pokemon.status_conditions.include?("freeze") && params["status"] == "burn"
      @defender.active_pokemon.status_conditions.delete("freeze")
      @events.push(@defender => "thaw")
    end
    status_seed = rand(100)
    inflict_status(params["status"], target) unless params["percentage"] && params["percentage"] < status_seed
  end

  def fixed_damage(params)
    @defender.active_pokemon.damage(params["damage"])
    damage_percentage = (params["damage"].to_f / @defender.active_pokemon.hp.to_f) * 100
    @events.push(@defender => {"damage" => damage_percentage})
  end

  def no_effect(params)
    @events.push(@attacker => "no_effect")
  end
end
