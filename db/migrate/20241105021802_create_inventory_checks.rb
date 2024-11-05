class CreateInventoryChecks < ActiveRecord::Migration[7.1]
  def change
    create_table :inventory_checks do |t|
      t.text :skus
      t.belongs_to :user, null: false, foreign_key: true
      t.timestamps
    end
  end
end
