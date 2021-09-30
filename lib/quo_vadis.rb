# frozen_string_literal: true

module QuoVadis

  Error = Class.new StandardError
  PasswordExistsError = Class.new QuoVadis::Error

  def self.accessor(*names)
    names.each do |name|
      define_singleton_method name do |val = nil|
        if !val.nil?
          instance_variable_set :"@#{name}", val
        else
          instance_variable_get :"@#{name}"
        end
      end
    end
  end

  accessor \
    :password_minimum_length,              # integer
    :mask_ips,                             # true | false
    :cookie_name,                          # string
    :session_lifetime,                     # :session | ActiveSupport::Duration | [integer] seconds
    :session_lifetime_extend_to_end_of_day,# true | false
    :session_idle_timeout,                 # :lifetime | ActiveSupport::Duration | [integer] seconds
    :password_reset_token_lifetime,        # ActiveSupport::Duration | [integer] seconds
    :mail_headers,                         # hash
    :accounts_require_confirmation,        # true | false
    :account_confirmation_token_lifetime,  # ActiveSupport::Duration | [integer] seconds
    :enqueue_transactional_emails,         # true | false
    :app_name,                             # string
    :two_factor_authentication_mandatory,  # true | false
    :mount_point                           # string

  class << self
    def configure(&block)
      module_eval &block
    end

    # name - string class name, e.g. 'User'
    # identifier - attribute symbol, e.g. :username
    def register_model(name, identifier)
      models[name] = identifier
    end

    def find_account_by_identifier_in_params(params)
      Account.find_by identifier: identifier_value_in_params(params)
    end

    def identifier_value_in_params(params)
      identifier = detect_identifier params.keys
      params[identifier]
    end

    # model - string class name, e.g. 'User'
    # returns string humanised name for the model's identifier, e.g. "Username"
    def humanise_identifier(model)
      klass = model.constantize
      klass.human_attribute_name identifier(model)
    end

    # Translates the key in the :quo_vadis scope, returning nil if it does not exist.
    # This allows applications to suppress a QuoVadis translation.
    # For example:
    #
    #     en:
    #       quo_vadis:
    #         require_authentication:
    #
    def translate(key, **options)
      I18n.t key, **options.merge(scope: :quo_vadis, raise: true) rescue nil
    end

    def notify(action, params)
      deliver(action, params, later: true)
    end

    def deliver(action, params, later: QuoVadis.enqueue_transactional_emails)
      mail = QuoVadis::Mailer.with(params).send(action)
      later ?
        mail.deliver_later :
        mail.deliver_now
    end

    # model - string class name, e.g. 'User'
    # returns attribute symbol, e.g. :username
    def identifier(model)
      models[model]
    end

    private

    def models
      @models ||= {}
    end

    def detect_identifier(candidates)
      (identifiers.map(&:to_s) & candidates.map(&:to_s)).first
    end

    def identifiers
      models.values.uniq
    end
  end
end

require_relative 'quo_vadis/defaults'
require_relative 'quo_vadis/engine'
require_relative 'quo_vadis/crypt'
require_relative 'quo_vadis/encrypted_type'
require_relative 'quo_vadis/hmacable'
require_relative 'quo_vadis/ip_masking'
require_relative 'quo_vadis/model'
require_relative 'quo_vadis/current_request_details'
require_relative 'quo_vadis/controller'

ActiveSupport.on_load(:action_controller) do
  include QuoVadis::Controller
end

ActiveSupport.on_load(:active_record) do
  include QuoVadis::Model
end

