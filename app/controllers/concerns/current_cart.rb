
module CurrentCart
  extend ActiveSupport::Concern

  included { helper_method :current_cart }

  private

  def current_cart
    @current_cart ||= begin
      cart = Cart.find_by(id: session[:cart_id])
      cart ||= Cart.create!(user: current_user)
      session[:cart_id] = cart.id
      cart.update(user: current_user) if current_user && cart.user_id.nil?
      cart
    end
  end
end
