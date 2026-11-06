module Admin
  class ProductsController < BaseController
    before_action :load_product, only: [:edit, :update, :destroy]
    before_action :load_categories, only: [:new, :create, :edit, :update]

    def index
      @query = params[:q].to_s
      @products = paginate(Product.includes(:category).search(@query).order(:name))
    end

    def new
      @product = Product.new
    end

    def create
      @product = Product.new(product_params)
      if @product.save
        redirect_to admin_products_path, notice: "Товар «#{@product.name}» додано."
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit; end

    def update
      if @product.update(product_params)
        redirect_to admin_products_path, notice: "Товар «#{@product.name}» оновлено."
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      if @product.destroy
        redirect_to admin_products_path, notice: "Товар видалено."
      else
        redirect_to admin_products_path, alert: "Не можна видалити товар, що є в замовленнях. Виставте залишок 0."
      end
    end

    # Форма масового додавання (JSON)
    def bulk; end

    def bulk_create
      @json = params[:json].to_s
      result = ProductImporter.new(@json).call
      if result.success?
        redirect_to admin_products_path, notice: "Додано товарів: #{result.products.size}."
      else
        @errors = result.errors
        render :bulk, status: :unprocessable_entity
      end
    end

    private

    def load_product = @product = Product.find(params[:id])
    def load_categories = @categories = Category.ordered

    def product_params
      params.require(:product).permit(:name, :category_id, :price, :stock_quantity, :sku, :image_url, :description)
    end
  end
end
