require 'rspec'
require './lib/damage'
require './lib/pokemon'
require './lib/move'

describe 'damage methods' do
  include Damage
  it 'calculates the correct damage' do
    damage_outputs = []
    damage_values = DamageValues.new(100, 55, 148, 198, 2)
    100.times do
      damage_outputs.push(damage_calculation(damage_values))
    end

    damage_outputs.sort!.uniq!

    expect(damage_outputs).to eq([62, 63, 64, 65, 66, 67, 68, 69, 70, 71, 72, 73])

    damage_outputs.clear

    damage_values = DamageValues.new(100, 35, 196, 196, 1)

    100.times do
      damage_outputs.push(damage_calculation(damage_values))
    end

    damage_outputs.sort!.uniq!

    expect(damage_outputs).to eq([26, 27, 28, 29, 30, 31])
  end

  it 'calculates the damage with abstracted information' do
    hp_values_1 = StatValues.new(15, 65535, 79)
    attack_values_1 = StatValues.new(15, 65535, 83)
    defense_values_1 = StatValues.new(15, 65535, 100)
    special_values_1 = StatValues.new(15, 65535, 85)
    speed_values_1 = StatValues.new(15, 65535, 78)
    blastoise = Pokemon.new("blah", 100, hp_values_1, attack_values_1, defense_values_1, special_values_1, speed_values_1, :water)

    hp_values_2 = StatValues.new(15, 65535, 90)
    attack_values_2 = StatValues.new(15, 65535, 110)
    defense_values_2 = StatValues.new(15, 65535, 80)
    special_values_2 = StatValues.new(15, 65535, 80)
    speed_values_2 = StatValues.new(15, 65535, 95)
    arcanine = Pokemon.new("blah", 100, hp_values_2, attack_values_2, defense_values_2, special_values_2, speed_values_2, :fire)

    move = Move.new("splat", 5, :water, 85)
    move.attack_move({"power" => 120})

    damage_outputs = []
    100.times do
      damage_outputs.push(damage(blastoise, arcanine, move))
    end

    damage_outputs.sort!.uniq!

    expected = [272, 273, 274, 276, 277, 278, 279, 281, 282, 283, 284, 286, 287, 288, 289, 291, 292, 293, 294, 296, 297, 298, 299, 301, 302, 303, 304, 306, 307, 308, 309, 311, 312, 313, 314, 316, 317, 318, 320]

    expect(damage_outputs).to eq(expected)
  end

  it 'does typing correctly' do
    expect(type_chart(:water, :fire)).to eq(2)
    expect(type_chart(:grass, :rock)).to eq(2)
    expect(type_chart(:normal, :normal)).to eq(1)
    expect(type_chart(:electric, :ground)).to eq(0)
    expect(type_chart(:water, :grass)).to eq(0.5)
  end
end
