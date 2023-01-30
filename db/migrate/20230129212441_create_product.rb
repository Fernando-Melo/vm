class CreateProduct < ActiveRecord::Migration[7.0]
  def change
    create_table :products do |t|
      t.integer :amount_available, null: false, default: 0
      t.integer :cost, null: false, default: 10000
      t.string :product_name, null: false
      t.references :seller, foreign_key: { to_table: 'users' }

      t.timestamps
    end
  end
end
