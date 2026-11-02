# Замовлення: дані одержувача, доставка, оплата та знімок позицій.
class Order < ApplicationRecord
  include UkrainianPhone

  DELIVERY_COSTS = { "nova_poshta" => 80, "ukrposhta" => 50, "courier" => 100, "pickup" => 0 }.freeze
  DELIVERY_LABELS = {
    "nova_poshta" => "Нова Пошта (відділення або поштомат)",
    "ukrposhta" => "Укрпошта (стандарт)",
    "courier" => "Кур'єр по місту",
    "pickup" => "Самовивіз з нашого магазину"
  }.freeze
  PAYMENT_LABELS = {
    "cash_on_delivery" => "Оплата при отриманні (післяплата)",
    "online_card" => "Банківська картка онлайн (Visa / Mastercard)",
    "iban_transfer" => "Оплата за реквізитами (IBAN)"
  }.freeze
  ATTRIBUTE_NAMES = {
    recipient_name: "Прізвище та ім'я", recipient_phone: "Номер телефону", city: "Місто",
    warehouse_or_address: "Відділення / адреса", delivery_method: "Спосіб доставки",
    payment_method: "Спосіб оплати", card_number: "Номер картки", card_expiry: "Термін дії картки",
    card_cvv: "CVV"
  }.freeze

  belongs_to :user
  has_many :order_items, dependent: :destroy

  enum :status, { in_progress: 0, completed: 1, cancelled: 2 }
  enum :delivery_method, { nova_poshta: 0, ukrposhta: 1, courier: 2, pickup: 3 }
  enum :payment_method, { cash_on_delivery: 0, online_card: 1, iban_transfer: 2 }
  enum :payment_status, { unpaid: 0, paid: 1, failed: 2 }

  # Дані тестової картки лише для симуляції; у базу НЕ зберігаються
  attr_accessor :card_number, :card_expiry, :card_cvv

  validates :recipient_name, presence: { message: "не може бути порожнім" }
  validates_ukrainian_phone :recipient_phone
  validates :city, :warehouse_or_address, presence: { message: "не може бути порожнім" }
  validates :card_number, format: { with: /\A\d{16}\z/, message: "має містити 16 цифр" }, if: :online_card?
  validates :card_expiry, format: { with: %r{\A(0[1-9]|1[0-2])/\d{2}\z}, message: "вкажіть у форматі ММ/РР" }, if: :online_card?
  validates :card_cvv, format: { with: /\A\d{3}\z/, message: "має містити 3 цифри" }, if: :online_card?

  def self.human_attribute_name(attr, options = {})
    ATTRIBUTE_NAMES[attr.to_sym] || super
  end

  def self.delivery_cost_for(method)
    DELIVERY_COSTS.fetch(method.to_s, 0)
  end

  def items_subtotal
    order_items.sum(&:subtotal)
  end

  def delivery_label = DELIVERY_LABELS[delivery_method]
  def payment_label = PAYMENT_LABELS[payment_method]
end
