# frozen_string_literal: true

module QuoVadis
  class Crypt

    def self.encrypt(value)
      return nil if value.nil?
      return '' if value == ''

      salt = SecureRandom.hex KEY_LENGTH
      crypt = encryptor key(salt)
      ciphertext = crypt.encrypt_and_sign value
      [salt, ciphertext].join SEPARATOR
    end

    def self.decrypt(value)
      return nil if value.nil?
      return '' if value == ''

      salt, data = value.split SEPARATOR
      crypt = encryptor key(salt)
      crypt.decrypt_and_verify(data)
    end

    private

    KEY_LENGTH = ActiveSupport::MessageEncryptor.key_len
    SEPARATOR = '$$'

    def self.encryptor(key)
      ActiveSupport::MessageEncryptor.new(key)
    end

    def self.key(salt)
      ActiveSupport::KeyGenerator.new(secret).generate_key(salt, KEY_LENGTH)
    end

    def self.secret
      Rails.application.secret_key_base
    end

  end
end
