# frozen_string_literal: true

module QuoVadis
  class ConfirmationsController < ApplicationController

    # holding page
    def index
      @account = find_pending_account_from_session
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

      session.delete :account_pending_confirmation

      login account.model, true
      redirect_to qv.path_after_signup, notice: QuoVadis.translate('flash.confirmation.confirmed')
    end


    def edit_email
      account = find_pending_account_from_session

      unless account
        redirect_to confirmations_path, alert: QuoVadis.translate('flash.confirmation.unknown') and return
      end

      @email = account.model.email
    end


    def update_email
      account = find_pending_account_from_session

      unless account
        redirect_to confirmations_path, alert: QuoVadis.translate('flash.confirmation.unknown') and return
      end

      account.model.update email: params[:email]

      request_confirmation account.model
      redirect_to confirmations_path
    end


    def resend
      account = find_pending_account_from_session

      unless account
        redirect_to confirmations_path, alert: QuoVadis.translate('flash.confirmation.unknown') and return
      end

      request_confirmation account.model
      redirect_to confirmations_path
    end


    private

    def find_pending_account_from_session
      Account.find(session[:account_pending_confirmation]) if session[:account_pending_confirmation]
    end

  end
end
