require './lib/roster'
require './lib/damage'
require './lib/move_effects'
require 'json'

class TurnProcessor
  attr_reader :roster_one, :roster_two, :events
  def initialize(game)
    @state = JSON.parse(game.game_states.last.data)
    @roster_one = Roster.from_data(game.roster_one_base, @state["roster_one"])
    @roster_two = Roster.from_data(game.roster_two_base, @state["roster_two"])
    @move_one = @roster_one.active_pokemon.move_by_name(@state["player_one_move"]["move"]) unless @state["player_one_move"]["move"].nil?
    @move_two = @roster_two.active_pokemon.move_by_name(@state["player_two_move"]["move"]) unless @state["player_two_move"]["move"].nil?
    @events = []
  end

  def run!
    switch
    ordered_rosters = speed_check
    ordered_rosters.each {|roster| take_turn(roster[:roster], roster[:opponent], roster[:move])} if ordered_rosters
  end

  def switch
    switch_pokemon(@roster_one, "player_one_move") unless @state["player_one_move"]["pokemon_switch"].nil?
    switch_pokemon(@roster_two, "player_two_move") unless @state["player_two_move"]["pokemon_switch"].nil?
  end

  private

  def switch_pokemon(roster, move_string)
    switch_value = @state[move_string]["pokemon_switch"]
    @events.push({roster => {"pokemon_switch" => roster.active_pokemon.name}})
    roster.switch(switch_value)
  end

  def accuracy_check(attacker, defender, move)
    if move.accuracy == 0
      return true
    else
      seed = rand(100) + 1
      return seed <= move.accuracy
    end
  end

  def speed_check
    set_1 = {roster: @roster_one, opponent: @roster_two, move: @move_one}
    set_2 = {roster: @roster_two, opponent: @roster_one, move: @move_two}
    if @move_one.nil? && @move_two.nil?
      nil
    elsif @move_one.nil?
      [set_2]
    elsif @move_two.nil?
      [set_1]
    elsif @move_two.priority && !@move_two.priority
      [set_1, set_2]
    elsif @move_two.priority && !@move_one.priority
      [set_2, set_1]
    elsif (@move_one.priority && @move_two.priority) && (@move_one.priority != @move_two.priority)
      [set_1, set_2].sort_by {|set| set[:move].priority * -1}
    else
      [set_1, set_2].sort_by {|set| set[:roster].active_pokemon.speed}
    end
  end

  def take_turn(attacker, defender, move)
    @events.push({attacker => {"move" => move.name}})
    if accuracy_check(attacker, defender, move)
      effects = MoveEffects.new(attacker, defender, move)
      effects.run!
      @events += effects.events
    else
      @events.push({attacker => "miss"})
    end
  end
end
