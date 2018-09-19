module Status
  def inflict_status(status, target)
    if status_validation(status, target)
      target.active_pokemon.status_conditions.push(status)
      @events.push(target => {"status" => status})
    end
  end

  def status_validation(status, target)
    return false if target.active_pokemon.status_conditions.include?(status)
    return false if status == "burn" && (target.active_pokemon.type_1 == :fire || target.active_pokemon.type_2 == :fire)
    return false if status == "freeze" && (target.active_pokemon.type_1 == :ice || target.active_pokemon.type_2 == :ice)
    return false if status == "poison" && (target.active_pokemon.type_1 == :poison || target.active_pokemon.type_2 == :poison)
    true
  end

  def burn_post(target)
    damage_value = target.active_pokemon.hp / 16
    damage_percentage = (damage_value.to_f / target.active_pokemon.hp.to_f) * 100
    @events.push(target => "burn_damage")
    @events.push(target => {"damage" => damage_percentage})
  end

  def poison_post(target)
    damage_value = target.active_pokemon.hp / 16
    damage_percentage = (damage_value.to_f / target.active_pokemon.hp.to_f) * 100
    @events.push(target => "poison_damage")
    @events.push(target => {"damage" => damage_percentage})
  end

  def post_status_check(target)
    target.active_pokemon.status_conditions.each do |status|
      send("#{status}_post", target) if respond_to?("#{status}_post")
    end
  end

  def freeze_pre(target)
    @events.push(target => "frozen")
    :skipped
  end

  def paralyze_pre(target)
    paralysis_seed = rand(100)
    if paralysis_seed < 25
      @events.push(target => "paralyzed")
      :skipped
    end
  end

  def flinch_pre(target)
    @events.push(target => "flinched")
    :skipped
  end

  def pre_status_check(target)
    skipped = false
    target.active_pokemon.status_conditions.each do |status|
      effect = send("#{status}_pre", target) if respond_to?("#{status}_pre")
      skipped = true if effect == :skipped
    end
    skipped
  end
end
