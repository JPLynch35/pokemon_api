require 'json'
require './lib/roster'

class MoveValidationService
  attr_reader :valid, :message
  def initialize(game, turn, uuid)
    @raw_state = game.game_states.last
    @state = JSON.parse(@raw_state.data)
    set_player_specifics(game, uuid)
    @already_sent = @state[@move_string]
    @already_sent = "move_open" if @already_sent.nil?
    @turn = turn["move"]
    @valid = true
    @message = ""
  end

  def check
    if @already_sent.class == Hash
      move_sent
    elsif @already_sent.class == String
      send(@already_sent)
    end
  end

  private

  def move_sent
    @valid = false
    @message = "You've already sent your move."
  end

  def skipped
    @valid = false
    @message = "Waiting on your opponent for more information"
  end

  def move_open
    if @turn["move"]
      move_check(@turn["move"])
    elsif @turn["pokemon_switch"]
      switch_check(@turn["pokemon_switch"])
    end
  end

  def death_switch
    if @turn["move"]
      @valid = false
      @message = "Your pokemon is dead. You needs to switch!"
    end
    if @turn["pokemon_switch"]
      switch_check(@turn["pokemon_switch"])
    end
  end

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

  def set_player_specifics(game, uuid)
    if uuid == game.player_one_uuid
      @roster = Roster.from_data(game.roster_one_base, @state["roster_one"])
      @move_string = "player_one_move"
    elsif uuid == game.player_two_uuid
      @roster = Roster.from_data(game.roster_two_base, @state["roster_two"])
      @move_string = "player_two_move"
    end
  end
end
