require 'json'
require './lib/roster'

class MoveValidationService
  attr_reader :valid, :message
  def initialize(game, turn, uuid)
    @state = JSON.parse(game.game_states.last.data)
    if uuid == game.player_one_uuid
      @roster = Roster.from_data(game.roster_one_base, @state["roster_one"])
      @already_sent = @state["player_one_move"]
    elsif uuid == game.player_two_uuid
      @roster = Roster.from_data(game.roster_two_base, @state["roster_two"])
      @already_sent = @state["player_two_move"]
    end
    @turn = turn["move"]
    @valid = true
    @message = ""
  end

  def check
    if @already_sent
      @valid = false
      @message = "You've already sent your move."
    elsif @turn["move"]
      move_check(@turn["move"])
    elsif @turn["switch"]
      switch_check(@turn["switch"])
    end
  end

  private

  def move_check(move_name)
    move = @roster.active_pokemon.move_by_name(move_name)
    if move
      unless move.current_pp > 0
        @valid = false
        @message = "That move is out of PP."
      end
    else
      @valid = false
      @message = "The pokemon doesn't have that move."
    end
  end

  def switch_check(pokemon_name)
    pokemon = @roster.pokemon_by_name(pokemon_name)
    if pokemon
      if pokemon.dead?
        @valid = false
        @message = "That one is dead."
      elsif pokemon == @roster.active_pokemon
        @valid = false
        @message = "That one is already out!"
      end
    else
      @valid = false
      @message = "You do not have that pokemon."
    end
  end
end
