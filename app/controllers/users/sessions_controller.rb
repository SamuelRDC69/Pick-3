# frozen_string_literal: true

module Users
  class SessionsController < ApplicationController
    skip_before_action :authenticate
    before_action :find_user, only: %i[create]
    before_action :authenticate_user, only: %i[create]

    def new; end

    def create
      session[:fantasy_sports_user_id] = @user.id
      redirect_to after_login_path, notice: t('controllers.users.sessions.success_create')
    end

    def destroy
      session[:fantasy_sports_user_id] = nil
      redirect_to after_logout_path, notice: t('controllers.users.sessions.success_destroy')
    end

    private

    def find_user
      @user = User.find_by(email: user_params[:email].downcase)
      return if @user.present?

      failed_sign_in
    end

    def authenticate_user
      return if @user.authenticate(user_params[:password])

      failed_sign_in
    end

    def failed_sign_in
      render :new, alert: t('controllers.users.sessions.invalid')
    end

    def after_login_path
      home_path
    end

    def after_logout_path
      root_path
    end

    def user_params
      params.require(:user).permit(:email, :password)
    end
  end
end
