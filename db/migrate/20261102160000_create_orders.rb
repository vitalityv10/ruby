# Скіл 6: замовлення з даними доставки та знімок позицій (order_items)
class CreateOrders < ActiveRecord::Migration[8.1]
  def change
    create_table :orders do |t|
      t.references :user, null: false, foreign_key: true
      t.integer :status, null: false, default: 0 # in_progress
      t.decimal :total_amount, precision: 10, scale: 2, null: false, default: 0
      t.string :recipient_name, null: false
      t.string :recipient_phone, null: false
      t.integer :delivery_method, null: false, default: 0
      t.string :city, null: false
      t.string :warehouse_or_address, null: false
      t.text :delivery_notes

      t.timestamps
    end

    create_table :order_items do |t|
      t.references :order, null: false, foreign_key: true
      t.references :product, null: false, foreign_key: true
      t.integer :quantity, null: false
      t.decimal :price_at_order, precision: 10, scale: 2, null: false

      t.timestamps
    end
  end
end
