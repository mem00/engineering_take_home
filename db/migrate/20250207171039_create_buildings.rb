class CreateBuildings < ActiveRecord::Migration[7.2]
  def change
    create_table :buildings do |t|
      t.string :address, null: false
      t.string :city, null: false
      t.string :state_abbr, null: false
      t.string :postal_code, null: false
      t.references :client, null: false, foreign_key: true, index: true
      t.timestamps
    end
  end
end
