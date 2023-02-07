class CreateAllowedlistedJwts < ActiveRecord::Migration[7.0]
  def change
    create_table :allowlisted_jwts do |t|
      t.references :user, foreign_key: { on_delete: :cascade }, null: false
      t.string :jti, null: false
      t.datetime :exp, null: false

      t.timestamps null: false
    end

    add_index :allowlisted_jwts, :jti, unique: true
  end
end
