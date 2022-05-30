require 'test_helper'

class CryptTest < ActiveSupport::TestCase

  setup do
    @crypt = QuoVadis::Crypt

    @crypt_sha1 = Class.new(QuoVadis::Crypt) do
      def self.encryptor(salt)
        key_sha1 = key salt, OpenSSL::Digest::SHA1
        ActiveSupport::MessageEncryptor.new key_sha1
      end
    end
  end

  test 'round trip' do
    plaintext = 'the quick brown fox'
    ciphertext = @crypt.encrypt plaintext
    refute_equal plaintext, ciphertext
    assert_equal plaintext, @crypt.decrypt(ciphertext)
  end

  test 'same plaintext encrypts to different ciphertexts' do
    plaintext = 'the quick brown fox'
    ciphertext = @crypt.encrypt plaintext
    refute_equal ciphertext, @crypt.encrypt(plaintext)
  end

  test 'rotation' do
    # This test only works if our test Rails contains this commit:
    # https://github.com/rails/rails/commit/447e28347eb46e2ad5dc625de616152bd1b69a32
    return unless ActiveSupport::KeyGenerator.respond_to? :hash_digest_class

    plaintext = 'the quick brown fox'
    # Encrypt with SHA1 digest
    ciphertext_sha1 = @crypt_sha1.encrypt plaintext
    # Ensure code can decrypt it.
    assert_equal plaintext, @crypt.decrypt(ciphertext_sha1)
  end

end
