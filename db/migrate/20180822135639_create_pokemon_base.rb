class CreatePokemonBase < ActiveRecord::Migration[5.1]
  def change
    create_table :pokemon_bases do |t|
      t.string :species_name
      t.integer :hp_iv
      t.integer :hp_ev
      t.integer :attack_iv
      t.integer :attack_ev
      t.integer :defense_iv
      t.integer :defense_ev
      t.integer :special_iv
      t.integer :special_ev
      t.integer :speed_iv
      t.integer :speed_ev
      t.string :move_one
      t.string :move_two
      t.string :move_three
      t.string :move_four
      t.references :roster_base, foreign_key: true
    end
  end
end
