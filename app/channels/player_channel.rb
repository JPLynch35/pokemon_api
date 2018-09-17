require 'json'
require './lib/turn_processor'

class PlayerChannel < ApplicationCable::Channel

  def subscribed
    stream_from "player_#{uuid}"
  end

  def receive(data)
    roster = RosterBase.find_by(name: data["add_pokemon"]["roster_name"])
    if data["add_pokemon"]
      pokemon_params = data.slice(:species_name, :attack_iv, :attack_ev, :defense_iv, :defense_ev, :special_iv, :special_ev, :speed_iv, :speed_ev)
      roster.pokemon_bases.create(pokemon_params)
      ActionCable.server.broadcast "player_#{uuid}", {
        message: "Roster Count: #{roster.pokemon_bases.count}"
      }
    end
  end

  def get_pokemon_data
    file = File.read('./data/pokemon.json')
    data_hash = JSON.parse(file)
    ActionCable.server.broadcast "player_#{uuid}", data_hash
  end

  def create_game
    game = Game.create(player_one_uuid: uuid)
    game.game_states.create
    ActionCable.server.broadcast "player_#{uuid}", {
      token: game.token
    }
  end

  def join_game(data)
    game = Game.find_by(token: data["token"])
    unless game.nil? || !game.player_two_uuid.nil?
      game.player_two_uuid = uuid
      game.save
      ActionCable.server.broadcast "player_#{uuid}", {
        join_status: "Game successfully joined!"
      }
      ActionCable.server.broadcast "player_#{game.player_one_uuid}", {
        message: "Player two successfully connected!"
      }
    else
      ActionCable.server.broadcast "player_#{uuid}", {
        join_status: "Unable to join game"
      }
    end
  end

  def send_message(data)
    game = Game.where('player_one_uuid=? OR player_two_uuid=?', uuid, uuid).first
    send_to = nil
    unless game.nil?
      if uuid == game.player_one_uuid
        send_to = game.player_two_uuid
      elsif uuid == game.player_two_uuid
        send_to = game.player_one_uuid
      end
    end
    ActionCable.server.broadcast "player_#{send_to}", {
      opponent_message: data["message"]
    }
  end

  def send_roster(data)
    game = Game.where('player_one_uuid=? OR player_two_uuid=?', uuid, uuid).first
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
    state = JSON.parse(game.game_states.last.data)
    if state[roster].nil?
      roster_add = RosterAdd.new(game, {roster: roster, data: data})
      roster_add.add
      state = JSON.parse(game.game_states.last.data)
      message = {}
      if state[other_roster].nil?
        ActionCable.server.broadcast "player_#{uuid}", {message: "Waiting for opponent to start game..."}
        service = DataFormatService.new
        game.game_states.create(data: {roster => service.roster_state(roster_add.starting_roster)}.to_json)
      else
        roster_one = Roster.from_data(game.roster_one_base)
        roster_two = Roster.from_data(game.roster_two_base)
        service = DataFormatService.from_rosters(roster_one, roster_two)
        game.game_states.create(data: service.state_json)
        player_one_args = service.arguments("one", game.player_one_uuid)
        player_two_args = service.arguments("two", game.player_two_uuid)
        ActionCable.server.broadcast player_one_args[0], player_one_args[1]
        ActionCable.server.broadcast player_two_args[0], player_two_args[1]
      end
    end
    game.save!
  end

  def send_turn(data)
    game = Game.where("player_one_uuid=? OR player_two_uuid=?", uuid, uuid).find_by(current_state: "active")
    if game.nil?
      ActionCable.server.broadcast "player_#{uuid}", {
        error: "There is no game to send a move to. It is possible that you or your partner accidentally disconnectes"
      }
    else
      player = ""
      opponent = ""
      if uuid == game.player_one_uuid
        player = {"player_one" => game.player_one_uuid}
        opponent = {"player_two" => game.player_two_uuid}
      elsif uuid == game.player_two_uuid
        player = {"player_two" => game.player_two_uuid}
        opponent = {"player_one" => game.player_two_uuid}
      end
      validation_service = MoveValidationService.new(game, data, uuid)
      validation_service.check
      if validation_service.valid
        state = JSON.parse(game.game_states.last.data)
        state["#{player.keys.first}_move"] = data["move"]
        last_state = game.game_states.last
        last_state.data = state.to_json
        last_state.save!
        if state["#{opponent.keys.first}_move"]
          processor = TurnProcessor.new(game)
          processor.run!
          format_service = DataFormatService.new(processor)
          game.game_states.create(data: format_service.state_json)
          player_one_args = format_service.arguments("one", game.player_one_uuid)
          player_two_args = format_service.arguments("two", game.player_two_uuid)
          ActionCable.server.broadcast player_one_args[0], player_one_args[1]
          ActionCable.server.broadcast player_two_args[0], player_two_args[1]
        else
          ActionCable.server.broadcast "player_#{uuid}", {
            message: "Waiting for opponent..."
          }
        end
        game.save!
      else
        ActionCable.server.broadcast "player_#{uuid}", {
          error: validation_service.message
        }
      end
    end
  end
end
