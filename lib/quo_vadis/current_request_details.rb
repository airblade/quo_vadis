# frozen_string_literal: true

module QuoVadis
  class CurrentRequestDetails < ActiveSupport::CurrentAttributes
    attribute :ip

    def request=(request)
      self.ip = request.remote_ip
    end
  end
end
