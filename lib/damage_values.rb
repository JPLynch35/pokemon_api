class DamageValues
  attr_accessor :level, :power, :attack, :defense, :modifier
  def initialize(level = 0, power = 0, attack = 0, defense = 0, modifier = 1)
    @level = level
    @power = power
    @attack = attack
    @defense = defense
    @modifier = modifier
  end
end
