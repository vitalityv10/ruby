module Admin
  class OrdersController < BaseController
    def index
      @status = params[:status].presence_in(Order.statuses.keys)
      scope = Order.includes(:user).order(created_at: :desc, id: :desc)
      scope = scope.where(status: @status) if @status
      @orders = paginate(scope)
    end

    def show
      @order = Order.includes(order_items: :product).find(params[:id])
    end

    # Зміна статусу за дозволеними переходами; скасування повертає товар на склад
    def update_status
      order = Order.find(params[:id])
      target = params[:status].to_s
      unless Order::TRANSITIONS.fetch(order.status, []).include?(target)
        return redirect_to admin_order_path(order), alert: "Цей перехід статусу неможливий."
      end
      target == "cancelled" ? order.cancel! : order.update!(status: target)
      redirect_to admin_order_path(order), notice: "Статус змінено: #{order.status_label}."
    end

    def mark_paid
      order = Order.find(params[:id])
      return redirect_to(admin_order_path(order), alert: "Замовлення вже оплачено або скасоване.") if order.paid? || order.cancelled?
      order.paid!
      redirect_to admin_order_path(order), notice: "Замовлення позначено як оплачене."
    end
  end
end
