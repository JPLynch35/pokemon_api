require 'json'

class DataFormatService
  attr_accessor :roster_one, :roster_two
  def initialize(processor = nil)
    unless processor.nil?
      @roster_one = processor.roster_one
      @roster_two = processor.roster_two
      @events = processor.events
    else
      @events = []
    end
  end

  def self.from_rosters(roster_one, roster_two)
    service = DataFormatService.new
    service.roster_one = roster_one
    service.roster_two = roster_two
    service
  end

  def state_json
    {roster_one: roster_state(@roster_one), roster_two: roster_state(@roster_two)}.to_json
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
        move_four: {current_pp: p.move_four.current_pp}
      }
    end
    return_value
  end

  def arguments(player, uuid)
    roster = nil
    opponent = nil
    if player == "one"
      roster = @roster_one.to_h
      opponent = opponent_view(@roster_two)
    elsif player == "two"
      roster = @roster_two.to_h
      opponent = opponent_view(@roster_one)
    end
    return_value = ["player_#{uuid}", {
      player_roster: roster,
      opponent_roster: opponent,
      events: format_events(player)
      }]
  end

  private

  def opponent_view(roster)
    {
      name: roster.active_pokemon.name,
      hp_percentage: roster.active_pokemon.hp_percentage,
      level: roster.active_pokemon.level
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
    @events.map do |event|
      {roster_text(player, event.keys.first) => event.values.first}
    end
  end
end
