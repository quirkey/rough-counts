# frozen_string_literal: true

class DeviseCreateUsers < ActiveRecord::Migration[7.1]
  def change
    create_table :users do |t|
      t.string :email, null: false, default: ""
      t.string :encrypted_password
      t.string :name
      t.string :provider
      t.string :uid
      t.string :access_token
      t.string :refresh_token
      t.datetime :refresh_token_expires_at
      t.timestamps null: false
    end

    add_index :users, :email, unique: true
    add_index :users, %i[provider uid], unique: true
  end
end
