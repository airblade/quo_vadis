# frozen_string_literal: true

module QuoVadis
  class Mailer < ::ActionMailer::Base

    def reset_password
      @url = params[:url]
      _mail params[:email], QuoVadis.translate('mailer.password_reset.subject')
    end

    def account_confirmation
      @url = params[:url]
      _mail params[:email], QuoVadis.translate('mailer.confirmation.subject')
    end

    def email_change_notification
      @timestamp = Time.now
      @ip = QuoVadis::CurrentRequestDetails.ip
      _mail params[:email], QuoVadis.translate('mailer.notification.email_change')
    end

    def identifier_change_notification
      @timestamp = Time.now
      @identifier = params[:identifier]
      @ip = QuoVadis::CurrentRequestDetails.ip
      _mail params[:email], QuoVadis.translate('mailer.notification.identifier_change',
                                               identifier: params[:identifier])
    end

    def password_change_notification
      @timestamp = Time.now
      @ip = QuoVadis::CurrentRequestDetails.ip
      _mail params[:email], QuoVadis.translate('mailer.notification.password_change')
    end

    def password_reset_notification
      @timestamp = Time.now
      @ip = QuoVadis::CurrentRequestDetails.ip
      _mail params[:email], QuoVadis.translate('mailer.notification.password_reset')
    end

    def totp_setup_notification
      @timestamp = Time.now
      @ip = QuoVadis::CurrentRequestDetails.ip
      _mail params[:email], QuoVadis.translate('mailer.notification.totp_setup')
    end

    def totp_reuse_notification
      @timestamp = Time.now
      @ip = QuoVadis::CurrentRequestDetails.ip
      _mail params[:email], QuoVadis.translate('mailer.notification.totp_reuse')
    end

    def twofa_deactivated_notification
      @timestamp = Time.now
      @ip = QuoVadis::CurrentRequestDetails.ip
      _mail params[:email], QuoVadis.translate('mailer.notification.twofa_deactivated')
    end

    def recovery_codes_generation_notification
      @timestamp = Time.now
      @ip = QuoVadis::CurrentRequestDetails.ip
      _mail params[:email], QuoVadis.translate('mailer.notification.recovery_codes_generation')
    end

    private

    def _mail(to, subject)
      mail QuoVadis.mail_headers.merge(to: to, subject: subject)
    end

  end
end
