class CreateBuildings < ActiveRecord::Migration[7.2]
  def change
    create_table :buildings do |t|
      t.string :address, null: false
      t.string :state
      t.string :zip
      t.references :client, null: false, foreign_key: true, index: true
      t.timestamps
    end
  end
end
