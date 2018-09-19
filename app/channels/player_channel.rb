require 'json'
require './lib/turn_processor'

class PlayerChannel < ApplicationCable::Channel

  def subscribed
    stream_from "player_#{uuid}"
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
    send_to = DataFormatService.find_other_uuid(game, uuid)
    ActionCable.server.broadcast "player_#{send_to}", {
      opponent_message: data["message"]
    }
  end

  def send_roster(data)
    game = Game.where('player_one_uuid=? OR player_two_uuid=?', uuid, uuid).first
    labels = RosterAdd.roster_labels(game, uuid)
    state = JSON.parse(game.game_states.last.data)
    if state[labels[:roster]].nil?
      roster_add = RosterAdd.new(game, {roster: labels[:roster], data: data})
      roster_add.add
      state = JSON.parse(game.game_states.last.data)
      if state[labels[:other_roster]].nil?
        ActionCable.server.broadcast "player_#{uuid}", {message: "Waiting for opponent to start game..."}
        service = DataFormatService.new
        game.game_states.create(data: {labels[:roster] => service.roster_state(roster_add.starting_roster)}.to_json)
      else
        arguments = roster_add.initial_data
        ActionCable.server.broadcast arguments[:player_one_args][0], arguments[:player_one_args][1]
        ActionCable.server.broadcast arguments[:player_two_args][0], arguments[:player_two_args][1]
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
      broadcast_data = TurnService.new(game, data, uuid).process
      broadcast_data.each {|message| ActionCable.server.broadcast message[0], message[1]}
    end
  end
end
