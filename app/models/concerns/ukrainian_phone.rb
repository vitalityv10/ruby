# Спільна валідація українського номера телефону (+380XXXXXXXXX, 380XXXXXXXXX, 0XXXXXXXXX).
# Пробіли, дужки та дефіси дозволені лише як роздільники.
module UkrainianPhone
  extend ActiveSupport::Concern

  PHONE_ERROR = "має некоректний формат (приклад: +38 044 123-45-67)".freeze

  class_methods do
    def validates_ukrainian_phone(attr)
      validates attr, presence: { message: "не може бути порожнім" }
      validate(if: -> { self[attr].present? }) do
        value = self[attr]
        digits = value.gsub(/\D/, "")
        ok = value.match?(/\A\+?[\d\s()\-]+\z/) && digits.match?(/\A(38)?0\d{9}\z/) &&
             (!value.start_with?("+") || digits.start_with?("38"))
        errors.add(attr, PHONE_ERROR) unless ok
      end
    end
  end
end
