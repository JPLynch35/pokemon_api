require './lib/damage'

class MoveEffects
  attr_reader :events
  include Damage
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
end
