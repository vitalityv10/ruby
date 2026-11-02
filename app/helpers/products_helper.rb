module ProductsHelper
  # Форматування ціни у гривнях: 1 249,00 грн
  def format_uah(amount)
    "#{number_with_delimiter(number_with_precision(amount, precision: 2), delimiter: ' ', separator: ',')} грн"
  end
end
