class SessionsController < ApplicationController
  def new
  end

  def create
    user = User.find_by(email: params[:email].to_s.strip.downcase)

    if user&.authenticate(params[:password])
      reset_session
      session[:user_id] = user.id
      redirect_to (user.admin? ? admin_root_path : root_path), notice: "Ви успішно увійшли!"
    else
      flash.now[:alert] = "Невірний email або пароль"
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    reset_session
    redirect_to root_path, notice: "Ви вийшли з системи."
  end
end
