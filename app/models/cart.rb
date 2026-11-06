# Кошик: належить користувачу (необов'язково — гості теж можуть мати кошик).
class Cart < ApplicationRecord
  belongs_to :user, optional: true
  has_many :line_items, dependent: :destroy

  # Додає товар або збільшує кількість, якщо він уже є в кошику.
  # Повертає false, якщо кількість у кошику досягла залишку на складі.
  def add_product(product_id)
    item = line_items.find_or_initialize_by(product_id: product_id)
    new_quantity = item.new_record? ? 1 : item.quantity + 1
    return false if new_quantity > item.product.stock_quantity

    item.quantity = new_quantity
    item.save!
    item
  end

  def total_price
    line_items.includes(:product).sum(&:subtotal)
  end

  def total_items
    line_items.sum(:quantity)
  end
end
