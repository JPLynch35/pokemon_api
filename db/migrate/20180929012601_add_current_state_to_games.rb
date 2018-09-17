class AddCurrentStateToGames < ActiveRecord::Migration[5.1]
  def change
    add_column :games, :current_state, :integer, default: 0
  end
end
