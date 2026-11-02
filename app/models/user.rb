class User < ApplicationRecord
  has_secure_password

  has_many :reviews, dependent: :destroy

  enum :role, { customer: 0, admin: 1 }

  before_validation { self.email = email.to_s.strip.downcase }

  validates :email, presence: { message: "не може бути порожньою" },
                    format: { with: URI::MailTo::EMAIL_REGEXP, message: "має неправильний формат" },
                    uniqueness: { case_sensitive: false, message: "вже зареєстрована" }
  validates :password, length: { minimum: 6, message: "має містити щонайменше 6 символів" }, allow_nil: true
  validates :first_name, presence: { message: "не може бути порожнім" }
  validates :last_name, presence: { message: "не може бути порожнім" }
  validates :phone, presence: { message: "не може бути порожнім" }, \
            format: { with: /\A\+380\d{9}\z/, message: "має бути у форматі +380XXXXXXXXX" }

  def full_name
    "#{first_name} #{last_name}"
  end
end
