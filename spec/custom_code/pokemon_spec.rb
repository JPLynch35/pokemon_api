require 'rspec'
require './lib/pokemon'
require './lib/stat_values'

describe 'stats' do
  it 'calculates the correct stats' do
    name = "Squirtle"
    hp_values = StatValues.new(15, 0, 79)
    attack_values = StatValues.new(15, 0, 83)
    defense_values = StatValues.new(15, 0, 100)
    special_values = StatValues.new(15, 0, 85)
    speed_values = StatValues.new(15, 0, 78)
    level = 56
    pokemon = Pokemon.new(name, level, hp_values, attack_values, defense_values, special_values, speed_values, :water)

    expect(pokemon.hp).to eq(171)
    expect(pokemon.attack).to eq(114)
    expect(pokemon.defense).to eq(133)
    expect(pokemon.special).to eq(117)
    expect(pokemon.speed).to eq(109)
  end

  it "calculates the correct stats from data" do
    user_input = {"hp_iv" => 15, "hp_ev" => 0, "attack_iv" => 13, "attack_ev" => 140, "defense_iv" => 12, "defense_ev" => 23, "special_iv" => 2, "special_ev" => 43, "speed_iv" => 4, "speed_ev" => 12, "level" => 53}
    pokemon = Pokemon.from_data("Abra", user_input)
    expect(pokemon.hp).to eq(105)
    expect(pokemon.attack).to eq(41)
    expect(pokemon.defense).to eq(34)
    expect(pokemon.special).to eq(119)
    expect(pokemon.speed).to eq(105)
  end
end
