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
      roster_params["team"][name]["species_name"] = name
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
    roster_params
  end

  def store_roster(roster)
    roster_base = RosterBase.create
    params = {}
    roster["team"].each do |name, data|
      roster_base.pokemon_bases.create(data)
    end
    if @roster_data[:roster] == "roster_one"
      @game.roster_one_base = roster_base
      @base = @game.roster_one_base
    elsif @roster_data[:roster] == "roster_two"
      @game.roster_two_base = roster_base
      @base = @game.roster_two_base
    end
  end

  def add
    roster = generate_roster
    store_roster(roster)
  end

  def starting_roster
    Roster.from_data(@base)
  end

  def self.roster_labels(game, uuid)
    roster = nil
    other_roster = nil
    other_uuid = nil
    if uuid == game.player_one_uuid
      roster = "roster_one"
      other_roster = "roster_two"
      other_uuid = game.player_two_uuid
    elsif uuid == game.player_two_uuid
      roster = "roster_two"
      other_roster = "roster_one"
      other_uuid = game.player_one_uuid
    end
    {roster: roster, other_roster: other_roster, other_uuid: other_uuid}
  end

  def initial_data
    roster_one = Roster.from_data(@game.roster_one_base)
    roster_two = Roster.from_data(@game.roster_two_base)
    service = DataFormatService.from_rosters(roster_one, roster_two)
    @game.game_states.create(data: service.state_json)
    player_one_args = service.arguments("one", @game.player_one_uuid)
    player_two_args = service.arguments("two", @game.player_two_uuid)
    {player_one_args: player_one_args, player_two_args: player_two_args}
  end
end
