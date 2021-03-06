# frozen_string_literal: true

module QuoVadis
  class PasswordResetsController < ApplicationController

    # holding page for after the create action
    def index
    end


    def new
    end


    def create
      account = QuoVadis.find_account_by_identifier_in_params params

      if account
        token = QuoVadis::PasswordResetToken.generate account
        QuoVadis.deliver :reset_password, email: account.model.email, url: quo_vadis.password_reset_url(token)
      end

      redirect_to password_resets_path, notice: QuoVadis.translate('flash.password_reset.create')
    end


    # emailed password-reset link points here
    def edit
      account = PasswordResetToken.find_account params[:token]

      unless account  # expired or password already changed
        redirect_to new_password_reset_path, alert: QuoVadis.translate('flash.password_reset.unknown') and return
      end

      # Ensure the flash notice set in the create action does not appear when the user clicks the
      # link in the email they were sent.
      flash.delete :notice

      @password = QuoVadis::Password.new
    end


    # really reset the password
    def update
      account = PasswordResetToken.find_account params[:token]

      unless account  # expired or password already changed
        redirect_to new_password_reset_path, alert: QuoVadis.translate('flash.password_reset.unknown') and return
      end

      @password = account.password
      if @password.reset params[:password][:password], params[:password][:password_confirmation]
        # Logout account's sessions because password has changed.
        # Note model is not logged in here.
        @password.account.sessions.destroy_all

        qv.log @password.account, Log::PASSWORD_RESET
        QuoVadis.notify :password_reset_notification, email: @password.account.model.email

        login @password.account.model, true
        redirect_to qv.path_after_authentication, notice: QuoVadis.translate('flash.password_reset.reset')
      else
        render :edit, status: :unprocessable_entity
      end
    end

  end
end
