require './lib/damage_values'
require 'pry'

module Damage
  def damage(attacker, defender, move)
    damage_values = DamageValues.new(attacker.level, move.power)
    physical_special(damage_values, attacker, defender, move)
    modifier(damage_values, attacker, defender, move)
    damage_values.level *= 2 if critical?(attacker)
    damage_calculation(damage_values)
  end

  def critical?(attacker)
    threshold = attacker.speed_values.base / 2
    random = rand(256)
    return random <= threshold
  end

  def stab(attacker, move)
    if attacker.type_1 == move.type || attacker.type_2 == move.type
      return 1.5
    else
      return 1
    end
  end

  def type_chart(attack_type, defense_type)
    types = [:normal, :fighting, :flying, :poison, :ground, :rock, :bug, :ghost, :fire, :water, :grass, :electric, :psychic, :ice, :dragon]
    attack = types.find_index(attack_type)
    defense = types.find_index(defense_type)
    chart =
    [
      [1.0, 1.0, 1.0, 1.0, 1.0, 0.5, 1.0, 0.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0],
      [2.0, 1.0, 0.5, 0.5, 1.0, 2.0, 0.5, 0.0, 1.0, 1.0, 1.0, 1.0, 0.5, 2.0, 1.0],
      [1.0, 2.0, 1.0, 1.0, 1.0, 0.5, 2.0, 1.0, 1.0, 1.0, 2.0, 0.5, 1.0, 1.0, 1.0],
      [1.0, 1.0, 1.0, 0.5, 0.5, 0.5, 2.0, 0.5, 1.0, 1.0, 2.0, 1.0, 1.0, 1.0, 1.0],
      [1.0, 1.0, 0.0, 2.0, 1.0, 2.0, 0.5, 1.0, 2.0, 1.0, 0.5, 2.0, 1.0, 1.0, 1.0],
      [1.0, 0.5, 2.0, 1.0, 0.5, 1.0, 2.0, 1.0, 2.0, 1.0, 1.0, 1.0, 1.0, 2.0, 1.0],
      [1.0, 0.5, 0.5, 2.0, 1.0, 1.0, 1.0, 0.5, 0.5, 1.0, 2.0, 1.0, 2.0, 1.0, 1.0],
      [0.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 2.0, 1.0, 1.0, 1.0, 1.0, 0.0, 1.0, 1.0],
      [1.0, 1.0, 1.0, 1.0, 1.0, 0.5, 2.0, 1.0, 0.5, 0.5, 2.0, 1.0, 1.0, 2.0, 0.5],
      [1.0, 1.0, 1.0, 1.0, 2.0, 2.0, 1.0, 1.0, 2.0, 0.5, 0.5, 1.0, 1.0, 1.0, 0.5],
      [1.0, 1.0, 0.5, 0.5, 2.0, 2.0, 0.5, 1.0, 0.5, 2.0, 0.5, 1.0, 1.0, 1.0, 0.5],
      [1.0, 1.0, 2.0, 1.0, 0.0, 1.0, 1.0, 1.0, 1.0, 2.0, 0.5, 0.5, 1.0, 1.0, 0.5],
      [1.0, 2.0, 1.0, 2.0, 1.0, 1.0, 1.0, 1.0, 1.0, 2.0, 0.5, 0.5, 1.0, 1.0, 0.5],
      [1.0, 1.0, 2.0, 1.0, 2.0, 1.0, 1.0, 1.0, 1.0, 0.5, 2.0, 1.0, 1.0, 0.5, 2.0],
      [1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0]
    ]
    chart[attack][defense]
  end

  def modifier(damage_values, attacker, defender, move)
    damage_values.modifier *= stab(attacker, move)
    damage_values.modifier *= type_chart(move.type, defender.type_1)
    damage_values.modifier *= type_chart(move.type, defender.type_2) unless defender.type_2.nil?
  end

  def physical_special(damage_values, attacker, defender, move)
    special_types = [:water, :grass, :fire, :ice, :electric, :psychic, :dragon]
    if special_types.include?(move.type)
      damage_values.attack = attacker.special
      damage_values.defense = defender.special
    else
      damage_values.attack = attacker.attack
      damage_values.defense = defender.defense
    end
  end

  def damage_rng
    range = rand(16)
    rng = 85 + range
    rng = rng.to_f / 100
    rng
  end

  def truncated_multiply(left, right)
    (left.to_f * right.to_f).to_i.to_f
  end

  def damage_calculation(damage_values)
    attack = damage_values.attack.to_f
    defense = damage_values.defense.to_f
    damage = truncated_multiply(2.0, damage_values.level)
    damage /= 5.0
    damage += 2.0
    damage = truncated_multiply(damage, damage_values.power)
    damage = truncated_multiply(damage, (attack/defense))
    damage /= 50.0
    damage += 2.0
    damage = truncated_multiply(damage, damage_values.modifier)
    damage = truncated_multiply(damage, damage_rng)
    damage.to_i
  end
end
