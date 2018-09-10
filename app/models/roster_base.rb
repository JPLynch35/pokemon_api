class RosterBase < ApplicationRecord
  has_many :pokemon_bases, class_name: 'PokemonBase'
end
