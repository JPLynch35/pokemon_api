require 'json'

class DataFormatService
  attr_accessor :roster_one, :roster_two
  attr_reader :state, :winner
  def initialize(processor = nil)
    unless processor.nil?
      @roster_one = processor.roster_one
      @roster_two = processor.roster_two
      @events = processor.events
      set_state
      death_check
      end_check
    else
      @events = []
    end
  end

  def self.find_other_uuid(game, uuid)
    unless game.nil?
      if uuid == game.player_one_uuid
        game.player_two_uuid
      elsif uuid == game.player_two_uuid
        game.player_one_uuid
      end
    end
  end

  def self.from_rosters(roster_one, roster_two)
    service = DataFormatService.new
    service.roster_one = roster_one
    service.roster_two = roster_two
    service.set_state
    service
  end

  def roster_state(roster)
    return_value = {
      active_pokemon: roster.active_pokemon.name
    }

    roster.pokemon.each do |p|
      return_value[p.name] = {
        current_hp: p.current_hp,
        move_one: {current_pp: p.move_one.current_pp},
        move_two: {current_pp: p.move_two.current_pp},
        move_three: {current_pp: p.move_three.current_pp},
        move_four: {current_pp: p.move_four.current_pp},
        status_conditions: p.status_conditions
      }
    end
    return_value
  end

  def arguments(player, uuid)
    rosters = rosters_from_string(player)
    return_value = ["player_#{uuid}", {
      player_roster: rosters[:roster].to_h,
      opponent_roster: opponent_view(rosters[:opponent]),
      events: format_events(player)
      }]
    return_value[1][:winner] = roster_text(roster_string(rosters[:roster]), @winner) if @winner
    return_value
  end

  def set_state
    @state = {roster_one: roster_state(@roster_one), roster_two: roster_state(@roster_two)}
  end

  private

  def opponent_view(roster)
    {
      name: roster.active_pokemon.name,
      hp_percentage: roster.active_pokemon.hp_percentage,
      level: roster.active_pokemon.level,
      status_conditions: roster.active_pokemon.status_conditions
    }
  end

  def roster_text(player, roster)
    if (player == "one" && roster == @roster_one) || (player == "two" && roster == @roster_two)
      "player"
    elsif (player == "one" && roster == @roster_two) || (player == "two" && roster == @roster_one)
      "opponent"
    end
  end

  def format_events(player)
    @events.map {|event| {roster_text(player, event.keys.first) => event.values.first} }
  end

  def check_for_loss(roster, potential_winner)
    loss = true
    roster.pokemon.each {|p| loss = false unless p.dead?}
    if loss
      @state[:winner] = "player_#{roster_string(potential_winner)}" if loss
      @events.push({potential_winner => "victory"})
      @winner = potential_winner
    end
  end

  def end_check
    check_for_loss(@roster_one, @roster_two)
    check_for_loss(@roster_two, @roster_one)
  end

  def death_check
    @state.merge!({player_one_move: "death_switch"}) if @roster_one.active_pokemon.dead?
    @state.merge!({player_two_move: "death_switch"}) if @roster_two.active_pokemon.dead?
    @state.merge!({player_one_move: "skipped"}) if @state[:player_two_move] && !@state[:player_one_move]
    @state.merge!({player_two_move: "skipped"}) if @state[:player_one_move] && !@state[:player_two_move]
  end

  def rosters_from_string(roster)
    return {roster: @roster_one, opponent: @roster_two} if roster == "one"
    return {roster: @roster_two, opponent: @roster_one} if roster == "two"
  end

  def roster_string(roster)
    return "one" if roster == @roster_one
    return "two" if roster == @roster_two
  end
end
