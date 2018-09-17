class CreateGames < ActiveRecord::Migration[5.1]
  def change
    create_table :games do |t|
      t.string :player_one_uuid
      t.string :player_two_uuid
      t.references :roster_one_base, foreign_key: { to_table: :roster_bases }, index: true
      t.references :roster_two_base, foreign_key: { to_table: :roster_bases }, index: true
    end
  end
end
