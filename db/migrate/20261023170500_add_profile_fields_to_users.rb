class AddProfileFieldsToUsers < ActiveRecord::Migration[8.1]
  def change
    change_column_null :users, :email, false
    change_column_null :users, :password_digest, false
    add_column :users, :first_name, :string, null: false, default: ""
    add_column :users, :last_name, :string, null: false, default: ""
    add_column :users, :phone, :string
    add_column :users, :role, :integer, null: false, default: 0
    add_index :users, :email, unique: true
  end
end
