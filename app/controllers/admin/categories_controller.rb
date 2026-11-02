module Admin
  class CategoriesController < BaseController
    def index
      @categories = Category.ordered.left_joins(:products).select("categories.*, COUNT(products.id) AS products_count").group("categories.id")
      @category = Category.new
    end

    def create
      @category = Category.new(params.require(:category).permit(:name, :description))
      if @category.save
        redirect_to admin_categories_path, notice: "Категорію «#{@category.name}» додано."
      else
        redirect_to admin_categories_path, alert: @category.errors.full_messages.to_sentence
      end
    end

    def destroy
      category = Category.find(params[:id])
      if category.destroy
        redirect_to admin_categories_path, notice: "Категорію видалено."
      else
        redirect_to admin_categories_path, alert: "Не можна видалити категорію, в якій є товари. Спершу перенесіть або видаліть товари."
      end
    end
  end
end
