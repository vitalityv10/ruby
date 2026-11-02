# Міграція: таблиця звернень клієнтів (форма зворотного зв'язку)
class CreateFeedbacks < ActiveRecord::Migration[8.1]
  def change
    create_table :feedbacks do |t|
      t.string :name, null: false
      t.string :email, null: false
      t.string :phone
      t.string :topic, null: false
      t.text :message, null: false
      t.integer :status, null: false, default: 0 # 0 - pending, 1 - resolved

      t.timestamps
    end
  end
end
