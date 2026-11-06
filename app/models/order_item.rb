# Позиція замовлення — «знімок» товару на момент покупки.
# price_at_order заморожується: якщо ціна товару зміниться пізніше, сума вже оформленого
# замовлення (і чек) не повинна змінюватись.
class OrderItem < ApplicationRecord
  belongs_to :order
  belongs_to :product

  validates :quantity, numericality: { only_integer: true, greater_than: 0 }
  validates :price_at_order, numericality: { greater_than_or_equal_to: 0 }

  def subtotal
    price_at_order * quantity
  end
end
