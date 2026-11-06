# Відповідь адміністратора на звернення + прив'язка звернення до акаунта (якщо клієнт був залогінений)
class AddReplyToFeedbacks < ActiveRecord::Migration[8.1]
  def change
    add_reference :feedbacks, :user, null: true, foreign_key: true
    add_column :feedbacks, :admin_reply, :text
    add_column :feedbacks, :replied_at, :datetime
  end
end
