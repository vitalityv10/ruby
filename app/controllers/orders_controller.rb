# Оформлення замовлення: доставка (скіл 6) і оплата (скіл 7).
class OrdersController < ApplicationController
  before_action :authenticate_user!

  def new
    return redirect_to(cart_path, alert: "Кошик порожній.") if current_cart.line_items.empty?
    @order = current_user.orders.new(recipient_name: current_user.full_name.strip,
                                     recipient_phone: current_user.phone)
  end

  def create
    result = OrderPlacer.new(cart: current_cart, user: current_user, params: order_params).call
    @order = result.order
    if result.success? && @order.persisted?
      redirect_to @order, notice: "Замовлення №#{@order.id} успішно оформлено!"
    else
      flash.now[:alert] = result.error if result.error
      render :new, status: :unprocessable_entity
    end
  end

  def show
    @order = current_user.orders.includes(order_items: :product).find(params[:id])
  end

  # Клієнт скасовує лише неоплачене й невідправлене замовлення (решту — через адміністратора)
  def cancel
    @order = current_user.orders.find(params[:id])
    mode = @order.cancellation_mode
    if mode == :self_service
      @order.cancel!
      redirect_to @order, notice: "Замовлення №#{@order.id} скасовано."
    else
      redirect_to @order, alert: cancel_denied_message(mode)
    end
  end

  private

  def cancel_denied_message(mode)
    case mode
    when :contact_admin then "Замовлення вже оплачено. Щоб скасувати його, зверніться до адміністратора."
    when :shipped then "Замовлення вже відправлено. Скасувати його не можна — після отримання можна оформити повернення."
    else "Це замовлення вже не можна скасувати."
    end
  end

  def order_params
    params.require(:order).permit(:recipient_name, :recipient_phone, :delivery_method, :city,
                                  :warehouse_or_address, :delivery_notes, :payment_method,
                                  :card_number, :card_expiry, :card_cvv)
  end
end
