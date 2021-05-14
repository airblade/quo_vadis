require 'test_helper'

class CryptTest < ActiveSupport::TestCase

  setup do
    @crypt = QuoVadis::Crypt
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

end
