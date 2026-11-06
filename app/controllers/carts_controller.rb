class CartsController < ApplicationController
  PER_PAGE = 5
  before_action :authenticate_user!

  def show
    scope = current_cart.line_items.includes(:product).order(:id)
    @total_pages = [(scope.count / PER_PAGE.to_f).ceil, 1].max
    @page = params[:page].to_i.clamp(1, @total_pages)
    @line_items = scope.limit(PER_PAGE).offset((@page - 1) * PER_PAGE)
  end
end
