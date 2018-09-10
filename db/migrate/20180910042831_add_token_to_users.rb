class AddTokenToUsers < ActiveRecord::Migration[5.1]
  def change
    add_column :games, :token, :string
    add_index :games, :token, unique: true
  end
end
