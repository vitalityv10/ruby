class CreateReviews < ActiveRecord::Migration[8.1]
  def change
    create_table :reviews do |t|
      t.integer :rating, null: false
      t.text :comment
      t.references :user, null: false, foreign_key: true
      t.references :product, null: false, foreign_key: true
      t.timestamps
    end
    # Унікальність: один відгук користувача на товар (дзеркало валідації моделі)
    add_index :reviews, [:user_id, :product_id], unique: true
  end
end
