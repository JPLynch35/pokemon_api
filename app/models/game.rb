class Game < ApplicationRecord
  has_secure_token
  has_many :game_states
  enum current_state: { active: 0, ended: 1 }

  def roster_one_base
    RosterBase.find(roster_one_base_id)
  end

  def roster_two_base
    RosterBase.find(roster_two_base_id)
  end

  def roster_one_base=(roster_base)
    self.roster_one_base_id = roster_base.id
  end

  def roster_two_base=(roster_base)
    self.roster_two_base_id = roster_base.id
  end
end
