# frozen_string_literal: true

module QuoVadis
  module Model

    def self.included(base)
      base.send :extend, ClassMethods
    end


    module ClassMethods
      def authenticates(identifier: :email)
        include InstanceMethodsOnActivation

        has_one :qv_account, as: :model, class_name: 'QuoVadis::Account', dependent: :destroy, autosave: true

        before_validation :qv_copy_identifier_to_account, if: Proc.new { |m| m.qv_account }

        validate :qv_copy_password_errors, if: Proc.new { |m| m.qv_account&.password }

        unless validators_on(identifier).any? { |v| ActiveRecord::Validations::UniquenessValidator === v }
          raise NotImplementedError, <<~END
            Missing uniqueness validation on #{name}##{identifier}.
            Try adding: `validates :#{identifier}, uniqueness: {case_sensitive: false}`
          END
        end

        define_method :qv_copy_identifier_to_account do
          qv_account.identifier = send identifier
        end

        after_update :qv_log_email_change, if: :saved_change_to_email?
        after_update :qv_notify_email_change, if: :saved_change_to_email?

        QuoVadis.register_model self.name, identifier
      end
    end


    module InstanceMethodsOnActivation
      attr_reader :password, :password_confirmation

      def password=(val)
        @password = val
        build_qv_account unless qv_account
        raise PasswordExistsError if qv_account.password&.persisted?
        (qv_account.password || qv_account.build_password).password = val
      end

      def password_confirmation=(val)
        @password_confirmation = val
        build_qv_account unless qv_account
        (qv_account.password || qv_account.build_password).password_confirmation = val
      end

      def revoke_authentication_credentials
        qv_account.revoke
      end

      private

      def qv_copy_password_errors
        qv_account.password.valid?  # force qv_account.password to validate
        qv_account.password.errors[:password             ].each { |message| errors.add :password,              message }
        qv_account.password.errors[:password_confirmation].each { |message| errors.add :password_confirmation, message }
      end

      def qv_log_email_change
        from, to = saved_change_to_email
        Log.create(
          account:  qv_account,
          action:   Log::EMAIL_CHANGE,
          ip:       (CurrentRequestDetails.ip || ''),
          metadata: {from: from, to: to}
        )
      end

      def qv_notify_email_change
        QuoVadis.notify :email_change_notification, email: saved_change_to_email[0]
      end
    end
  end
end
