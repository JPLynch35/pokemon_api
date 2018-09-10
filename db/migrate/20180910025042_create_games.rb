class CreateGames < ActiveRecord::Migration[5.1]
  def change
    create_table :games do |t|
      t.string :player_one_uuid
      t.string :player_two_uuid
    end
  end
end
