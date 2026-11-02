class Product < ApplicationRecord
  belongs_to :category
  has_many :reviews, dependent: :destroy

  validates :name, presence: true
  validates :price, numericality: { greater_than: 0 }
  validates :stock_quantity, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :sku, uniqueness: true, allow_blank: true

  scope :in_category, ->(id) { where(category_id: id) if id.present? }
  scope :search, ->(q) { where("products.name LIKE ?", "%#{sanitize_sql_like(q.strip)}%") if q.present? }
  scope :in_stock, -> { where("stock_quantity > 0") }

  # Середня оцінка: SQL-агрегація AVG, одне число замість завантаження всіх відгуків
  def average_rating
    reviews.average(:rating)&.to_f&.round(1)
  end

  def in_stock?
    stock_quantity.positive?
  end
end
