class AddGoogleToUsers < ActiveRecord::Migration[7.1]
  def change
    change_table :users do |t|
      t.string :email, null: false, default: ""
    end
    add_index :users, :email
  end
end
