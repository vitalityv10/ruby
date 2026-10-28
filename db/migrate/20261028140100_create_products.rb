class CreateProducts < ActiveRecord::Migration[8.1]
  def change
    create_table :products do |t|
      t.string :name, null: false
      t.text :description
      t.decimal :price, precision: 10, scale: 2, null: false
      t.integer :stock_quantity, null: false, default: 0
      t.string :sku
      t.string :image_url
      t.references :category, null: false, foreign_key: true
      t.timestamps
    end
    add_index :products, :sku, unique: true
    add_index :products, :name
  end
end
