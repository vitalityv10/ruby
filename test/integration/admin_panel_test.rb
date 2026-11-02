require "test_helper"

class AdminPanelTest < ActionDispatch::IntegrationTest
  setup do
    @admin = User.create!(email: "adm@example.com", password: "password123", first_name: "А", last_name: "Д", phone: "+380441234567", role: :admin)
    @user = User.create!(email: "u@example.com", password: "password123", first_name: "І", last_name: "П", phone: "+380441234567")
    @cat = Category.create!(name: "Котушки", slug: "reels")
  end

  def login(u) = post(login_path, params: { email: u.email, password: "password123" })

  test "доступ лише для адміна" do
    get admin_root_path
    assert_redirected_to login_path
    login(@user)
    get admin_products_path
    assert_redirected_to root_path
    login(@admin)
    get admin_root_path
    assert_response :success
  end

  test "додавання, редагування і видалення товару" do
    login(@admin)
    post admin_products_path, params: { product: { name: "Котушка A", category_id: @cat.id, price: 500, stock_quantity: 4, sku: "K-1" } }
    p = Product.last
    assert_equal "Котушка A", p.name
    patch admin_product_path(p), params: { product: { price: 600 } }
    assert_equal 600, p.reload.price
    get admin_products_path
    assert_response :success
    delete admin_product_path(p)
    assert_equal 0, Product.count
  end

  test "імпорт JSON: успіх і відкат при помилці" do
    login(@admin)
    ok = [{ name: "Т1", category: "котушки", price: 10, stock_quantity: 1, sku: "J1" }, { name: "Т2", category: "Котушки", price: 20, stock_quantity: 2 }].to_json
    post bulk_create_admin_products_path, params: { json: ok }
    assert_equal 2, Product.count
    bad = [{ name: "Т3", category: "Котушки", price: 5 }, { name: "Т4", category: "Немає", price: 5 }].to_json
    post bulk_create_admin_products_path, params: { json: bad }
    assert_response :unprocessable_entity
    assert_equal 2, Product.count
    post bulk_create_admin_products_path, params: { json: "{не json" }
    assert_response :unprocessable_entity
  end

  test "категорії: додавання, slug, заборона видалення з товарами" do
    login(@admin)
    post admin_categories_path, params: { category: { name: "Приманки та воблери" } }
    c = Category.find_by(name: "Приманки та воблери")
    assert_equal "prymanky-ta-voblery", c.slug
    Product.create!(name: "X", price: 1, stock_quantity: 1, category: c)
    delete admin_category_path(c)
    assert Category.exists?(c.id)
    delete admin_category_path(@cat)
    assert_not Category.exists?(@cat.id)
  end

  test "замовлення: переходи статусів і скасування" do
    pr = Product.create!(name: "X", price: 100, stock_quantity: 1, category: @cat)
    o = @user.orders.create!(recipient_name: "І", recipient_phone: "+380441234567", city: "К", warehouse_or_address: "1", total_amount: 100, status: :completed, payment_status: :paid)
    o.order_items.create!(product: pr, quantity: 1, price_at_order: 100)
    login(@admin)
    patch update_status_admin_order_path(o, status: "delivered") # недозволений перехід
    assert o.reload.completed?
    patch update_status_admin_order_path(o, status: "shipped")
    assert o.reload.shipped?
    patch update_status_admin_order_path(o, status: "delivered")
    assert o.reload.delivered?
    get admin_orders_path(status: "delivered")
    assert_response :success
  end

  test "відповідь на звернення: акаунт і пошта" do
    f = Feedback.create!(name: "І", email: "u@example.com", phone: "+380441234567", topic: "Співпраця", message: "Привіт", user: @user)
    login(@admin)
    assert_emails 1 do
      patch reply_admin_feedback_path(f), params: { admin_reply: "Дякуємо!", send_email: "1" }
    end
    assert f.reload.resolved?
    login(@user)
    get profile_path
    assert_match "Дякуємо!", response.body
  end
end

class AdminOnlyPanelTest < ActionDispatch::IntegrationTest
  test "адмін після входу потрапляє в панель, а сторінки магазину перенаправляють у неї" do
    User.create!(email: "adm3@example.com", password: "password123", first_name: "А", last_name: "Д", phone: "+380441234567", role: :admin)
    post login_path, params: { email: "adm3@example.com", password: "password123" }
    assert_redirected_to admin_root_path
    [root_path, cart_path, profile_path, contact_path, new_order_path].each do |path|
      get path
      assert_redirected_to admin_root_path, path
    end
    get admin_root_path
    assert_response :success
    assert_no_match "Кошик", response.body
    assert_no_match "site-footer", response.body
  end
end
