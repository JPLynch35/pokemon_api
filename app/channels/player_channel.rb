require 'json'

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
      RosterAdd.new(game, {roster: roster, data: data}).add
      state = JSON.parse(game.game_states.last.data)
      message = {}
      if state[other_roster].nil?
        ActionCable.server.broadcast "player_#{uuid}", {message: "Waiting for opponent to start game..."}
      else
        ActionCable.server.broadcast "player_#{uuid}", {
          player_data: state[roster],
          opponent_data: state[other_roster]["active_pokemon"]
        }
        ActionCable.server.broadcast "player_#{other_uuid}", {
          player_data: state[other_roster],
          opponent_data: state[roster]["active_pokemon"]
        }
      end
    end
  end
end
