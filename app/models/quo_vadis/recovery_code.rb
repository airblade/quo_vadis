# frozen_string_literal: true

module QuoVadis
  class RecoveryCode < ActiveRecord::Base
    belongs_to :account

    has_secure_password :code
    before_validation { send("code=", self.class.generate_code) unless code }

    # Returns true and destroys this instance if the plaintext code is authentic, false otherwise.
    def authenticate_code(plaintext_code)
      !!(destroy if super)
    end

    private

    CODE_LENGTH = 11  # odd number

    # Returns a string of length CODE_LENGTH, with two hexadecimal groups
    # separated by a hyphen.
    def self.generate_code
      group_length = (CODE_LENGTH - 1) / 2
      SecureRandom.hex(group_length).insert(group_length, '-')
    end
  end
end
