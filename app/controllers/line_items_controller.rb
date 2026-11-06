class LineItemsController < ApplicationController
  before_action :authenticate_user!
  def create
    product = Product.find(params[:product_id])
    return redirect_back_or_to(product_path(product), alert: "Товару немає в наявності") unless product.in_stock?
    if current_cart.add_product(product.id)
      redirect_back_or_to cart_path, notice: "Товар додано до кошика"
    else
      redirect_back_or_to cart_path, alert: "Недостатньо товару на складі: у кошику вже максимальна кількість"
    end
  end

  def update
    item = current_cart.line_items.find(params[:id])
    qty = item.quantity + params[:change].to_i
    if qty <= 0
      item.destroy
    elsif qty > item.product.stock_quantity
      return redirect_to cart_path, alert: "Недостатньо товару на складі"
    else
      item.update!(quantity: qty)
    end
    redirect_to cart_path
  end

  def destroy
    current_cart.line_items.find(params[:id]).destroy
    redirect_to cart_path, notice: "Товар видалено з кошика"
  end
end
