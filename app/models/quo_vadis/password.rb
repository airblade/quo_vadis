# frozen_string_literal: true

module QuoVadis
  class Password < ActiveRecord::Base
    belongs_to :account

    has_secure_password

    validates_length_of :password, minimum: QuoVadis.password_minimum_length, allow_blank: true
    validate :password_updated_legitimately, on: :update

    attr_accessor :new_password


    def change(current_plaintext, new_plaintext, new_plaintext_confirmation)
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

    def password_updated_legitimately
      return unless password_digest_changed?

      unless change_or_reset_called?
        errors.add :password, 'must be updated via #change or #reset'
      end
    end

    def change_or_reset_called?
      # Thread::Backtrace::Location#label changed in Ruby 3.4
      caller_locations.any? { |loc|
        if loc.respond_to? :base_label
          ["QuoVadis::Password#change", "QuoVadis::Password#reset"].include?(loc.label)
        else
          ['change', 'reset'].include?(loc.label) && Pathname.new(loc.path).basename.to_s == 'password.rb'
        end
      }
    end
  end
end
