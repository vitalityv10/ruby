# Лист клієнту з відповіддю адміністратора на його звернення
class FeedbackMailer < ApplicationMailer
  def reply(feedback)
    @feedback = feedback
    mail(to: feedback.email, subject: "Відповідь на ваше звернення — Рибальський дворик")
  end
end
