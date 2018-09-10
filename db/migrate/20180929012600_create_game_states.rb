class CreateGameStates < ActiveRecord::Migration[5.1]
  def change
    create_table :game_states do |t|
      t.string :data, default: "{}"
      t.references :game, foreign_key: true
    end
  end
end
