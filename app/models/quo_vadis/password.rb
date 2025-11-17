# frozen_string_literal: true

module QuoVadis
  class Password < ActiveRecord::Base
    belongs_to :account

    has_secure_password

    validates_length_of :password, minimum: QuoVadis.password_minimum_length, allow_blank: true
    validate :permitted_update, on: :update

    attr_accessor :new_password


    def change(current_plaintext, new_plaintext, new_plaintext_confirmation)
      permit_password_update

      unless authenticate current_plaintext
        errors.add :password, :incorrect
        return false
      end

      # has_secure_password ignores empty passwords ("") on update so reject them here.
      if new_plaintext.empty?
        errors.add :new_password, :blank
        return false
      end

      self.password = new_plaintext
      self.password_confirmation = new_plaintext_confirmation

      if save
        true
      else
        errors.delete(:password)&.each { |e| errors.add :new_password, e }
        errors.delete(:password_confirmation)&.each { |e| errors.add :new_password_confirmation, e }
        false
      end
    end


    def reset(new_plaintext, new_plaintext_confirmation)
      permit_password_update

      # has_secure_password ignores empty passwords ("") on update so reject them here.
      if new_plaintext.empty?
        errors.add :password, :blank
        return false
      end

      self.password = new_plaintext
      self.password_confirmation = new_plaintext_confirmation
      if save
        # Logout account's sessions because password has changed.
        # Assumes model is not logged in.
        account.sessions.destroy_all
        true
      end
    end

    private

    def permit_password_update
      @permit_password_update = true
    end

    def permit_password_update?
      @permit_password_update
    end

    def permitted_update
      return unless password_digest_changed?
      return if permit_password_update?

      errors.add :password, 'must be updated via #change or #reset'
    end
  end
end
