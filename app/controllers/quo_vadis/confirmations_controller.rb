# frozen_string_literal: true

module QuoVadis
  class ConfirmationsController < ApplicationController

    # holding page
    def index
    end


    # form for requesting new confirmation email
    def new
    end


    # send new confirmation email form submits here
    def create
      account = QuoVadis.find_account_by_identifier_in_params params

      unless account
        redirect_to new_confirmation_path, alert: QuoVadis.translate('flash.confirmation.identifier') and return
      end

      request_confirmation account.model
      redirect_to confirmations_path
    end


    # emailed confirmation link points here
    def edit
      account = AccountConfirmationToken.find_account params[:token]

      unless account  # expired or already confirmed
        redirect_to new_confirmation_path, alert: QuoVadis.translate('flash.confirmation.unknown') and return
      end
    end


    # confirm the account (and login)
    def update
      account = AccountConfirmationToken.find_account params[:token]

      unless account  # expired or already confirmed
        redirect_to new_confirmation_path, alert: QuoVadis.translate('flash.confirmation.unknown') and return
      end

      account.confirmed!

      qv.log account, Log::ACCOUNT_CONFIRMATION

      login account.model, true
      redirect_to qv.path_after_authentication, notice: QuoVadis.translate('flash.confirmation.confirmed')
    end

  end
end
