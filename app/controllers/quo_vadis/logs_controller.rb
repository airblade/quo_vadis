# frozen_string_literal: true

module QuoVadis
  class LogsController < QuoVadisController
    before_action :require_password_authentication

    PER_PAGE = 25

    def index
      logs = authenticated_model.qv_account.logs

      page = params[:page] ? params[:page].to_i : 1
      @logs = logs.new_to_old.page(page, PER_PAGE)

      @prev_page = page - 1 if page > 1
      @next_page = page + 1 if logs.count > page * PER_PAGE
    end

  end
end
