# Особистий кабінет: дані користувача та історія його замовлень.
class ProfilesController < ApplicationController
  PER_PAGE = 5
  before_action :authenticate_user!

  def show
    scope = current_user.orders.includes(order_items: :product).order(created_at: :desc, id: :desc)
    @total_pages = [(scope.count / PER_PAGE.to_f).ceil, 1].max
    @page = params[:page].to_i.clamp(1, @total_pages)
    # Звернення користувача (за акаунтом або поштою) з відповідями адміністратора
    @feedbacks = Feedback.where(user_id: current_user.id).or(Feedback.where(email: current_user.email)).order(created_at: :desc).limit(10)
    @orders = scope.limit(PER_PAGE).offset((@page - 1) * PER_PAGE)
  end
end
