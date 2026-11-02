# Артикул товару, якого стосується звернення
class AddSkuToFeedbacks < ActiveRecord::Migration[8.1]
  def change
    add_column :feedbacks, :sku, :string
  end
end
