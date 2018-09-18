class TurnService
  def initialize(game, data, uuid)
    @game = game
    @data = data
    @uuid = uuid
    if uuid == game.player_one_uuid
      @player = {"player_one" => game.player_one_uuid}
      @opponent = {"player_two" => game.player_two_uuid}
    elsif uuid == game.player_two_uuid
      @player = {"player_two" => game.player_two_uuid}
      @opponent = {"player_one" => game.player_two_uuid}
    end
    @validation_service = MoveValidationService.new(game, data, uuid)
    @validation_service.check
  end

  def process
    return_value = nil
    if @validation_service.valid
      state = store_move
      if state["#{@opponent.keys.first}_move"]
        arguments = process_turn
        return_value = [[arguments[:player_one_args][0], arguments[:player_one_args][1]], [arguments[:player_two_args][0], arguments[:player_two_args][1]]]
      else
        return_value = [["player_#{@uuid}", {message: "Waiting for opponent..."}]]
      end
      @game.save!
    else
      return_value = [["player_#{@uuid}", {error: validation_service.message}]]
    end
    return_value
  end

  private

  def process_turn
    processor = TurnProcessor.new(@game)
    processor.run!
    format_service = DataFormatService.new(processor)
    @game.game_states.create(data: format_service.state_json)
    {player_one_args: format_service.arguments("one", @game.player_one_uuid),
    player_two_args: format_service.arguments("two", @game.player_two_uuid)}
  end

  def store_move
    state = JSON.parse(@game.game_states.last.data)
    state["#{@player.keys.first}_move"] = @data["move"]
    last_state = @game.game_states.last
    last_state.data = state.to_json
    last_state.save!
    state
  end
end
