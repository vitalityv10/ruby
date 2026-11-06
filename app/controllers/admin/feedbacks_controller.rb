module Admin
  class FeedbacksController < BaseController
    def index
      @filter = params[:status].presence_in(Feedback.statuses.keys)
      scope = Feedback.order(created_at: :desc)
      scope = scope.where(status: @filter) if @filter
      @feedbacks = paginate(scope)
    end

    def show
      @feedback = Feedback.find(params[:id])
    end

    # Відповідь зберігається в акаунті клієнта (видно в профілі) і, за бажанням, надсилається на пошту
    def reply
      @feedback = Feedback.find(params[:id])
      text = params[:admin_reply].to_s.strip
      return redirect_to(admin_feedback_path(@feedback), alert: "Введіть текст відповіді.") if text.blank?

      @feedback.update!(admin_reply: text, replied_at: Time.current, status: :resolved)
      note = "Відповідь збережено."
      if params[:send_email] == "1"
        begin
          FeedbackMailer.reply(@feedback).deliver_now
          note += " Лист надіслано на #{@feedback.email}."
        rescue StandardError => e
          Rails.logger.error("Feedback mail failed: #{e.message}")
          return redirect_to(admin_feedback_path(@feedback), alert: "Відповідь збережено, але лист надіслати не вдалося.")
        end
      end
      redirect_to admin_feedback_path(@feedback), notice: note
    end
  end
end
