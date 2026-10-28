require "test_helper"

class CartFlowTest < ActionDispatch::IntegrationTest
  test "додавання, зміна кількості та видалення" do
    c = Category.create!(name: "К", slug: "k")
    p = Product.create!(name: "Воблер", price: 100, stock_quantity: 5, category: c)
    2.times { post line_items_path(product_id: p.id) }
    follow_redirect!
    assert_match "Кошик (2)", response.body
    assert_match "200,00 грн", response.body
    item = LineItem.last
    patch line_item_path(item, change: -1)
    assert_equal 1, item.reload.quantity
    delete line_item_path(item)
    assert_equal 0, LineItem.count
  end
end

class CartLimitTest < ActionDispatch::IntegrationTest
  test "не можна додати більше, ніж є на складі" do
    c = Category.create!(name: "К", slug: "k")
    p = Product.create!(name: "Воблер", price: 100, stock_quantity: 3, category: c)
    5.times { post line_items_path(product_id: p.id) }
    assert_equal 3, LineItem.last.quantity
  end
end
