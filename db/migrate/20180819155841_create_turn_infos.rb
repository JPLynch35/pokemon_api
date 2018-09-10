class CreateTurnInfos < ActiveRecord::Migration[5.1]
  def change
    create_table :turn_infos do |t|
      t.text :data

      t.timestamps
    end
  end
end
