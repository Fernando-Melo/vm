class AddCurrentLoginTokenToUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :current_login_token, :string
  end
end
