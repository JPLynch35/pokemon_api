class CreateRosterBase < ActiveRecord::Migration[5.1]
  def change
    create_table :roster_bases do |t|
      t.string :name
    end
  end
end
