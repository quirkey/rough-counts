# frozen_string_literal: true

class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def square
    @user = User.from_omniauth(request.env["omniauth.auth"])

    if @user.persisted?
      flash[:notice] = "Logged in with Square successfully."
      sign_in_and_redirect @user, event: :authentication
    else
      session["devise.square_data"] = request.env["omniauth.auth"].except("extra") # Removing extra as it can overflow some session stores
      flash[:alert] = @user.errors.full_messages.join("\n")
      redirect_to new_user_session_path
    end
  end
end
