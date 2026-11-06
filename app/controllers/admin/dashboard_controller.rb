module Admin
  class DashboardController < BaseController
    def index
      @counts = {
        products: Product.count, categories: Category.count,
        orders_new: Order.completed.count, orders_shipped: Order.shipped.count,
        feedbacks_new: Feedback.pending.count
      }
    end
  end
end
