# frozen_string_literal: true

module QuoVadis
  class Crypt

    def self.encrypt(value)
      return nil if value.nil?
      return '' if value == ''

      salt = SecureRandom.hex KEY_LENGTH
      crypt = encryptor salt
      ciphertext = crypt.encrypt_and_sign value
      [salt, ciphertext].join SEPARATOR
    end

    def self.decrypt(value)
      return nil if value.nil?
      return '' if value == ''

      salt, data = value.split SEPARATOR
      crypt = encryptor salt
      crypt.decrypt_and_verify(data)
    end

    private

    KEY_LENGTH = ActiveSupport::MessageEncryptor.key_len
    SEPARATOR = '$$'

    def self.encryptor(salt)
      key_sha256 = key salt, OpenSSL::Digest::SHA256
      key_sha1   = key salt, OpenSSL::Digest::SHA1
      ActiveSupport::MessageEncryptor.new(key_sha256).tap { |crypt|
        crypt.rotate key_sha1
      }
    end

    def self.key(salt, hash_digest_class)
      ActiveSupport::KeyGenerator
        .new(secret, hash_digest_class: hash_digest_class)
        .generate_key(salt, KEY_LENGTH)
    end

    def self.secret
      Rails.application.secret_key_base
    end

  end
end
