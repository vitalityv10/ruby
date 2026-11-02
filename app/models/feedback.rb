# Звернення клієнта: питання щодо снастей, замовлення, гарантії, співпраці.
class Feedback < ApplicationRecord
  TOPICS = [
    "Консультація щодо снастей",
    "Питання по замовленню",
    "Гарантія та повернення",
    "Співпраця"
  ].freeze

  TOPICS_REQUIRING_SKU = ["Консультація щодо снастей", "Гарантія та повернення"].freeze

  # Українські назви полів для повідомлень про помилки (замість "Sku", "Name" тощо)
  ATTRIBUTE_NAMES = {
    name: "Ім'я", email: "Електронна пошта", phone: "Телефон",
    sku: "Артикул товару", topic: "Тема звернення", message: "Повідомлення"
  }.freeze

  def self.human_attribute_name(attr, options = {})
    ATTRIBUTE_NAMES[attr.to_sym] || super
  end

  # status: 0 - очікує обробки, 1 - опрацьовано
  enum :status, { pending: 0, resolved: 1 }

  validates :name, presence: { message: "не може бути порожнім" }
  validates :email, presence: { message: "не може бути порожнім" },
                    format: { with: URI::MailTo::EMAIL_REGEXP, message: "має некоректний формат" },
                    allow_blank: true
  # Телефон обов'язковий, український формат: +380XXXXXXXXX, 380XXXXXXXXX або 0XXXXXXXXX.
  # Пробіли, дужки та дефіси дозволені лише як роздільники (перевіряємо після їх видалення).
  validates :phone, presence: { message: "не може бути порожнім" }
  validate :phone_format, if: -> { phone.present? }
  validates :topic, presence: { message: "потрібно вибрати" },
                    inclusion: { in: TOPICS, message: "обрано некоректно" }, allow_blank: true
  # Артикул обов'язковий для питань щодо снастей та гарантії
  validates :sku, presence: { message: "потрібно вказати для цієї теми (артикул є на сторінці товару)" },
                  if: -> { TOPICS_REQUIRING_SKU.include?(topic) }
  validates :message, presence: { message: "не може бути порожнім" }

  private

  def phone_format
    valid_chars = phone.match?(/\A\+?[\d\s()\-]+\z/) && !phone.start_with?("-")
    digits = phone.gsub(/\D/, "")
    unless valid_chars && digits.match?(/\A(38)?0\d{9}\z/) && (!phone.start_with?("+") || digits.start_with?("38"))
      errors.add(:phone, "має некоректний формат (приклад: +38 044 123-45-67)")
    end
  end
end
