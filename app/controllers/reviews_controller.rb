class ReviewsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_product

  def create
    review = @product.reviews.new(review_params.merge(user: current_user))
    if review.save
      redirect_to product_path(@product), notice: "Дякуємо за відгук!"
    else
      redirect_to product_path(@product), alert: review.errors.full_messages.to_sentence
    end
  end

  def destroy
    review = @product.reviews.find(params[:id])
    if review.user_id == current_user.id || current_user.admin?
      review.destroy
      redirect_to product_path(@product), notice: "Відгук видалено"
    else
      redirect_to product_path(@product), alert: "Немає прав для видалення відгуку"
    end
  end

  private

  def set_product
    @product = Product.find(params[:product_id])
  end

  def review_params
    params.require(:review).permit(:rating, :comment)
  end
end
