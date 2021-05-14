# frozen_string_literal: true

module QuoVadis
  class EncryptedType < ActiveRecord::Type::Value

    def deserialize(value)
      Crypt.decrypt(value)
    end

    def serialize(value)
      Crypt.encrypt(value)
    end

  end
end

ActiveRecord::Type.register :qv_encrypted, QuoVadis::EncryptedType
