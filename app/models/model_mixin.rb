require 'bcrypt'

module ModelMixin

  def self.included(base)
    base.send :extend, ClassMethods
  end

  module ClassMethods
    def authenticates
      send :include, InstanceMethodsOnActivation

      attr_reader    :password
      attr_protected :password_digest

      validates :username,        :presence => true, :uniqueness => true
      validates :password,        :presence => true, :if => Proc.new { |u| u.changed.include?('password_digest') }
      validates :password_digest, :presence => true

      scope :valid_token, lambda { |token| where("token = ? AND token_created_at > ?", token, 3.hours.ago) }

      instance_eval <<-END
        def authenticate(username, plain_text_password)
          user = where(:username => username).first
          if user && user.has_matching_password?(plain_text_password)
            user
          else
            nil
          end
        end
      END
    end
  end

  module InstanceMethodsOnActivation
    def password=(plain_text_password)
      @password = plain_text_password
      self.password_digest = BCrypt::Password.create plain_text_password
    end

    def generate_token
      begin
        self.token = url_friendly_token
      end while self.class.exists?(:token => token)
      self.token_created_at = Time.now.utc
      save
    end

    def clear_token
      update_attributes :token => nil, :token_created_at => nil
    end

    def has_matching_password?(plain_text_password)
      BCrypt::Password.new(password_digest) == plain_text_password
    end

    private

    def url_friendly_token
      ActiveSupport::SecureRandom.base64(10).tr('+/=', 'xyz')
    end
  end

end
