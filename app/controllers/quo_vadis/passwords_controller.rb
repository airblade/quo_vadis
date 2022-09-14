# frozen_string_literal: true

module QuoVadis
  class PasswordsController < QuoVadisController

    before_action :require_authentication

    def edit
      @password = QuoVadis::Password.new
    end

    def update
      @password = authenticated_model.qv_account.password
      if @password.change(params[:password][:password],
                          params[:password][:new_password],
                          params[:password][:new_password_confirmation])
        qv.log authenticated_model.qv_account, Log::PASSWORD_CHANGE
        QuoVadis.notify :password_change_notification, email: authenticated_model.email
        qv.logout_other_sessions
        qv.replace_session
        redirect_to qv.path_after_password_change, notice: QuoVadis.translate('flash.password.update')
      else
        render :edit, status: :unprocessable_entity
      end
    end

  end
end
