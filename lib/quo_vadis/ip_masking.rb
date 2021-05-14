# frozen_string_literal: true

require 'ipaddr'

module QuoVadis
  module IpMasking

    def self.included(base)
      base.extend ClassMethods
      base.before_validation :mask_ip, if: -> { QuoVadis.mask_ips }
    end

    def mask_ip
      self.ip = self.class.mask_ip ip
    end

    module ClassMethods
      # Based on Google Analytics masking
      # https://support.google.com/analytics/answer/2763052
      def mask_ip(ip)
        addr = IPAddr.new ip
        if addr.ipv4?
          addr.mask(24).to_s  # set last octet to 0
        else
          addr.mask(48).to_s  # set last 80 bits to 0
        end
      end
    end

  end
end
