# Масове додавання товарів із JSON. Усе в одній транзакції: якщо хоч один товар
# некоректний — не зберігається жоден, а користувач бачить, який саме запис помилковий.
# Формат: [{"name": "...", "category": "Назва категорії", "price": 100, "stock_quantity": 5,
#           "sku": "RD-1", "description": "...", "image_url": "..."}, ...]
class ProductImporter
  Result = Struct.new(:products, :errors, keyword_init: true) do
    def success? = errors.empty?
  end

  FIELDS = %w[name price stock_quantity sku description image_url].freeze

  def initialize(json)
    @json = json.to_s
  end

  def call
    data = JSON.parse(@json)
    data = data["products"] if data.is_a?(Hash)
    return fail_with("JSON має бути масивом товарів.") unless data.is_a?(Array) && data.any?

    errors = []
    products = []
    categories = Category.all.index_by { |c| c.name.downcase }
    data.each_with_index do |row, idx|
      n = idx + 1
      unless row.is_a?(Hash)
        errors << "Запис №#{n}: має бути об'єктом."
        next
      end
      category = categories[row["category"].to_s.strip.downcase] || Category.find_by(id: row["category_id"])
      errors << "Запис №#{n}: категорію «#{row['category'] || row['category_id']}» не знайдено." unless category
      product = Product.new(row.slice(*FIELDS).merge(category: category))
      errors.concat(product.errors.full_messages.map { |m| "Запис №#{n}: #{m}" }) unless category.nil? || product.valid?
      products << product
    end
    skus = products.map(&:sku).compact_blank
    (skus.tally.select { |_, c| c > 1 }.keys).each { |s| errors << "Артикул «#{s}» повторюється в JSON." }
    return Result.new(products: [], errors: errors) if errors.any?

    Product.transaction { products.each(&:save!) }
    Result.new(products: products, errors: [])
  rescue JSON::ParserError => e
    fail_with("Некоректний JSON: #{e.message.lines.first.to_s.strip}")
  end

  private

  def fail_with(msg) = Result.new(products: [], errors: [msg])
end
