# Скіл 7: спосіб і статус оплати, вартість доставки
class AddPaymentToOrders < ActiveRecord::Migration[8.1]
  def change
    add_column :orders, :payment_method, :integer, null: false, default: 0
    add_column :orders, :payment_status, :integer, null: false, default: 0
    add_column :orders, :delivery_cost, :decimal, precision: 10, scale: 2, null: false, default: 0
  end
end
