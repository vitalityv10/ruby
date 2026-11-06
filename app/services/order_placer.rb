# Сервіс оформлення замовлення. Уся операція виконується в ОДНІЙ транзакції:
# або виконуються всі кроки (перевірка складу, списання, оплата, очищення кошика),
# або при будь-якій помилці все відкочується і база лишається без змін.
class OrderPlacer
  class OutOfStock < StandardError; end
  class PaymentFailed < StandardError; end

  Result = Struct.new(:order, :error, keyword_init: true) do
    def success? = error.nil?
  end

  def initialize(cart:, user:, params:)
    @cart = cart
    @user = user
    @params = params
  end

  def call
    order = @user.orders.new(@params)
    return Result.new(order: order, error: "Кошик порожній.") if @cart.line_items.empty?
    return Result.new(order: order) unless order.valid? # помилки покаже форма

    ActiveRecord::Base.transaction do
      items = @cart.line_items.includes(:product).order(:id).to_a
      # lock! перечитує товар з блокуванням рядка (на SQLite — серіалізація запису),
      # тож два одночасні замовлення не спишуть один і той самий залишок двічі.
      items.each do |li|
        product = li.product.lock!
        raise OutOfStock, "Товару «#{product.name}» недостатньо на складі (залишилось #{product.stock_quantity})." if product.stock_quantity < li.quantity
        product.update!(stock_quantity: product.stock_quantity - li.quantity)
        order.order_items.build(product: product, quantity: li.quantity, price_at_order: product.price)
      end

      order.delivery_cost = Order.delivery_cost_for(order.delivery_method)
      order.total_amount = order.items_subtotal + order.delivery_cost
      order.payment_status = simulate_payment(order)
      # Відхилена оплата — відкочуємо всю транзакцію (склад і кошик не змінюються)
      raise PaymentFailed, "Оплату карткою відхилено. Перевірте дані картки або оберіть інший спосіб." if order.failed?
      order.status = :completed
      order.save!
      @cart.line_items.destroy_all
    end
    Result.new(order: order)
  rescue OutOfStock, PaymentFailed => e
    Result.new(order: order, error: e.message)
  end

  private

  # Симуляція оплати: картка з коректними даними — paid; картка 0000... — відмова; решта — unpaid
  def simulate_payment(order)
    return :unpaid unless order.online_card?
    order.card_number.start_with?("0000") ? :failed : :paid
  end
end
