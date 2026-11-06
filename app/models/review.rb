# Відгук: оцінка 1..5; коментар обов'язковий лише при оцінці нижче 3.
class Review < ApplicationRecord
  LOW_RATING_THRESHOLD = 3

  belongs_to :user
  belongs_to :product

  validates :rating, presence: { message: "потрібно вибрати" },
                     inclusion: { in: 1..5, message: "має бути від 1 до 5" }
  # Оцінка < 3 — коментар обов'язковий (мінімум 5 символів)
  validates :comment, presence: { message: "обов'язковий при оцінці нижче 3" },
                      length: { minimum: 5, message: "має містити щонайменше 5 символів" },
                      if: :comment_required?
  # Оцінка >= 3 — коментар необов'язковий, але якщо є, то мінімум 5 символів
  validates :comment, length: { minimum: 5, message: "має містити щонайменше 5 символів" },
                      allow_blank: true
  validates :user_id, uniqueness: { scope: :product_id, message: "Ви вже залишили відгук для цього товару" }

  def comment_required?
    rating.present? && rating < LOW_RATING_THRESHOLD
  end

  def stars
    "★" * rating.to_i + "☆" * (5 - rating.to_i)
  end
end
