require './lib/pokemon'

class Roster
  attr_reader :pokemon
  def initialize(pokemon, active = 0)
    @pokemon = pokemon
    @active_pokemon = pokemon[active]
  end

  def switch(index)
    @active_pokemon = @pokemon[index]
  end

  def to_h
    return_value = {}
    @pokemon.each do |p|
      return_value[p.name] = p.to_h
    end
    return_value
  end

  def self.from_data(user_input)
    pokemon = []
    team = user_input["team"]
    team.each do |key, value|
      pokemon.push(Pokemon.from_data(key, value))
    end
    Roster.new(pokemon)
  end
end
