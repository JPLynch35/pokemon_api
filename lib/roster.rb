require './lib/pokemon'

class Roster
  attr_reader :pokemon, :active_pokemon
  def initialize(pokemon, active = 0)
    @pokemon = pokemon
    @active_pokemon = pokemon.first
  end

  def pokemon_by_name(name)
    @pokemon.each do |p|
      return p if name == p.name
    end
    false
  end

  def switch(name)
    @active_pokemon = @pokemon.find {|p| p.name == name}
  end

  def to_h
    return_value = {}
    @pokemon.each do |p|
      return_value[p.name] = p.to_h
    end
    return_value[:active_pokemon] = @active_pokemon.to_h
    return_value
  end

  def self.from_data(roster_base, current_values = nil)
    pokemon = roster_base.pokemon_bases.map do |pokemon_base|
      pokemon_update = nil
      pokemon_update = current_values[pokemon_base.species_name] unless current_values.nil?
      Pokemon.from_data(pokemon_base, pokemon_update)
    end
    roster = Roster.new(pokemon)
    roster.switch(current_values["active_pokemon"]) unless current_values.nil?
    roster
  end
end
