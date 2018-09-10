class Game < ApplicationRecord
  has_secure_token
  has_many :game_states
end
