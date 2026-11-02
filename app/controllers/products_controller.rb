class ProductsController < ApplicationController
  PER_PAGE = 3

  def index
    @categories = Category.ordered
    @current_category = Category.find_by(id: params[:category_id])
    @query = params[:q].to_s

    scope = Product.includes(:category).in_category(params[:category_id]).search(@query).order(:name)

    @total_count = scope.count
    @total_pages = [(@total_count / PER_PAGE.to_f).ceil, 1].max
    @page = params[:page].to_i.clamp(1, @total_pages)
    @products = scope.limit(PER_PAGE).offset((@page - 1) * PER_PAGE)
  end

  def show
    @product = Product.includes(:category).find(params[:id])
  end
end
