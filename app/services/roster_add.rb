require './lib/roster'
require 'json'

class RosterAdd
  def initialize(game, roster_data)
    @game = game
    @roster_data = roster_data
  end

  def generate_roster
    roster_params = {"team" => {}}
    @roster_data[:data]["roster"].each do |name, moves|
      roster_params["team"][name] = {}
      roster_params["team"][name]["move_one"] = moves["moves"][0]
      roster_params["team"][name]["move_two"] = moves["moves"][1]
      roster_params["team"][name]["move_three"] = moves["moves"][2]
      roster_params["team"][name]["move_four"] = moves["moves"][3]
      roster_params["team"][name]["level"] = 100
      roster_params["team"][name]["hp_iv"] = 15
      roster_params["team"][name]["attack_iv"] = 15
      roster_params["team"][name]["defense_iv"] = 15
      roster_params["team"][name]["special_iv"] = 15
      roster_params["team"][name]["speed_iv"] = 15
      roster_params["team"][name]["hp_ev"] = 65535
      roster_params["team"][name]["attack_ev"] = 65535
      roster_params["team"][name]["defense_ev"] = 65535
      roster_params["team"][name]["special_ev"] = 65535
      roster_params["team"][name]["speed_ev"] = 65535
    end
    roster_params["active_pokemon"] = @roster_data[:data]["roster"].keys.first
    roster_params
  end

  def store_roster(roster)
    state = JSON.parse(@game.game_states.last.data)
    state[@roster_data[:roster]] = roster
    @game.game_states.create(data: state.to_json)
  end

  def add
    roster = generate_roster
    store_roster(roster)
  end
end
