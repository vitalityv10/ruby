# Контролер сторінки «Контакти»: показ форми та збереження звернення.
class FeedbacksController < ApplicationController
  def new
    @feedback = Feedback.new
  end

  def create
    @feedback = Feedback.new(feedback_params.merge(user: current_user))
    if @feedback.save
      redirect_to contact_path,
        notice: "Дякуємо! Ваше звернення прийнято. Наш рибальський експерт зв'яжеться з вами."
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  # Strong parameters: дозволяємо лише потрібні поля (status клієнт задавати не може)
  def feedback_params
    params.require(:feedback).permit(:name, :email, :phone, :sku, :topic, :message)
  end
end
