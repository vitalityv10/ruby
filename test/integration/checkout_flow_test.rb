require "test_helper"

class CheckoutFlowTest < ActionDispatch::IntegrationTest
  setup do
    @user = User.create!(email: "buyer@example.com", password: "password123", first_name: "Іван", last_name: "Петренко", phone: "+380441234567")
    post login_path, params: { email: "buyer@example.com", password: "password123" }
    c = Category.create!(name: "К", slug: "k")
    @product = Product.create!(name: "Воблер", price: 100, stock_quantity: 5, category: c)
    2.times { post line_items_path(product_id: @product.id) }
  end

  def order_params(extra = {})
    { order: { recipient_name: "Іван Петренко", recipient_phone: "+380441234567", delivery_method: "nova_poshta",
               city: "Київ", warehouse_or_address: "Відділення 5", payment_method: "cash_on_delivery" }.merge(extra) }
  end

  test "успішне оформлення: списання складу, знімок ціни, очищення кошика" do
    post orders_path, params: order_params
    order = Order.last
    assert_redirected_to order_path(order)
    assert_equal 280, order.total_amount # 2*100 + 80 доставка
    assert_equal 3, @product.reload.stock_quantity
    assert_equal 100, order.order_items.first.price_at_order
    assert_equal 0, LineItem.count
    assert order.unpaid?
  end

  test "оплата карткою позначає замовлення оплаченим" do
    post orders_path, params: order_params(payment_method: "online_card", card_number: "4111111111111111", card_expiry: "12/28", card_cvv: "123")
    assert Order.last.paid?
  end

  test "відхилена картка відкочує транзакцію" do
    post orders_path, params: order_params(payment_method: "online_card", card_number: "0000111122223333", card_expiry: "12/28", card_cvv: "123")
    assert_response :unprocessable_entity
    assert_equal 0, Order.count
    assert_equal 5, @product.reload.stock_quantity
    assert_equal 1, LineItem.count
  end

  test "недостатньо товару на складі" do
    @product.update!(stock_quantity: 1)
    post orders_path, params: order_params
    assert_response :unprocessable_entity
    assert_equal 0, Order.count
    assert_equal 1, @product.reload.stock_quantity
  end

  test "некоректні дані показують форму з помилками" do
    post orders_path, params: order_params(recipient_phone: "123", city: "")
    assert_response :unprocessable_entity
    assert_match "Номер телефону", response.body
  end
end

class ProfileTest < ActionDispatch::IntegrationTest
  test "профіль показує замовлення користувача, гість перенаправляється" do
    get profile_path
    assert_redirected_to login_path
    u = User.create!(email: "p@example.com", password: "password123", first_name: "Іван", last_name: "П", phone: "+380441234567")
    post login_path, params: { email: "p@example.com", password: "password123" }
    c = Category.create!(name: "К", slug: "k2")
    pr = Product.create!(name: "Блешня", price: 50, stock_quantity: 3, category: c)
    o = u.orders.create!(recipient_name: "І", recipient_phone: "+380441234567", city: "Київ", warehouse_or_address: "1", total_amount: 50)
    o.order_items.create!(product: pr, quantity: 1, price_at_order: 50)
    get profile_path
    assert_response :success
    assert_match "Блешня × 1", response.body
  end
end

class OrderCancelTest < ActionDispatch::IntegrationTest
  setup do
    @user = User.create!(email: "c@example.com", password: "password123", first_name: "І", last_name: "П", phone: "+380441234567")
    @admin = User.create!(email: "a@example.com", password: "password123", first_name: "А", last_name: "Д", phone: "+380441234567", role: :admin)
    @product = Product.create!(name: "Спінінг", price: 100, stock_quantity: 3, category: Category.create!(name: "К", slug: "k3"))
  end

  def make_order(attrs = {})
    o = @user.orders.create!({ recipient_name: "І", recipient_phone: "+380441234567", city: "Київ",
                               warehouse_or_address: "1", total_amount: 100, status: :completed }.merge(attrs))
    o.order_items.create!(product: @product, quantity: 1, price_at_order: 100)
    @product.update!(stock_quantity: 2)
    o
  end

  def login(u) = post(login_path, params: { email: u.email, password: "password123" })

  test "неоплачене скасовується клієнтом, склад повертається" do
    login(@user); o = make_order
    patch cancel_order_path(o)
    assert o.reload.cancelled?
    assert_equal 3, @product.reload.stock_quantity
  end

  test "оплачене клієнт скасувати не може — звернутися до адміна" do
    login(@user); o = make_order(payment_status: :paid)
    patch cancel_order_path(o)
    assert o.reload.completed?
    assert_match "адміністратора", flash[:alert]
  end

  test "відправлене скасувати не можна" do
    login(@user); o = make_order(status: :shipped)
    patch cancel_order_path(o)
    assert o.reload.shipped?
  end

end
