require './lib/roster'
require './lib/speed'
require './lib/damage'
require 'json'

class Game
  attr_reader :roster_1, :roster2
  include Damage
  def initialize(roster_1, roster_2)
    @roster_1 = roster_1
    @roster_2 = roster_2
  end

  def self.turn_interface(turn_1, turn_2)
    input_1 = JSON.parse(turn_1)
    input_2 = JSON.parse(turn_2)
    move_1 = Move.from_data(input_1["move"])
    move_2 = Move.from_data(input_2["move"])
    roster_1 = Roster.from_data(input_1["roster"])
    roster_2 = Roster.from_data(input_2["roster"])
    game = Game.new(roster_1, roster_2)
    game.turn(move_1, move_2)
    [game.roster_1.to_h, game.roster_2.to_h]
  end

  def accuracy_check(attacker, defender, move)
    if move.accuracy == 0
      return true
    else
      seed = rand(100) + 1
      return seed <= move.accuracy
    end
  end

  def speed_check(roster_1, roster_2, move_1, move_2)
    if move_1.move_type == "switch"
      return {first_roster: roster_1, second_roster: roster_2, first_move: move_1, second_move: move_2}
    elsif move_2.move_type == "switch"
      return {first_roster: roster_2, second_roster: roster_1, first_move: move_2, second_move: move_1}
    elsif move_1.priority && !move_2.priority
      return {first_roster: roster_1, second_roster: roster_2, first_move: move_1, second_move: move_2}
    elsif move_2.priority && !move_1.priority
      return {first_roster: roster_2, second_roster: roster_1, first_move: move_2, second_move: move_1}
    elsif move_1.priority && move_2.priority
      if move_1.priority > move_2.priority
        return {first_roster: roster_1, second_roster: roster_2, first_move: move_1, second_move: move_2}
      elsif move_2.priority > move_1.priority
        return {first_roster: roster_2, second_roster: roster_1, first_move: move_2, second_move: move_1}
      end
    end
    rosters = [{roster_1 => move_1}, {roster_2 => move_2}].shuffle.sort_by {|roster| roster.keys.first.active_pokemon.speed * -1}
    return {first_roster: rosters.first.keys.first, second_roster: rosters.last.keys.first, first_move: rosters.first.values.first, second_move: rosters.last.values.first}
  end

  def take_turn(attacker, defender, move)
    if accuracy_check(attacker, defender, move)
      unless move.power.nil?
        defender.current_hp -= damage(attacker, defender, move)
      end
    end
  end

  def turn(move_1, move_2)
    ordered_rosters = speed_check(@roster_1, @roster_2, move_1, move_2)
    take_turn(ordered_rosters[:first_roster].active_pokemon, ordered_rosters[:second_roster].active_pokemon, ordered_rosters[:first_move])
    take_turn(ordered_rosters[:second_roster].active_pokemon, ordered_rosters[:first_roster].active_pokemon, ordered_rosters[:second_move])
  end
end
