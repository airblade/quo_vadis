require 'bcrypt'

module ModelMixin

  def self.included(base)
    base.send :extend, ClassMethods
  end

  module ClassMethods
    # Adds methods to set and authenticate against a password stored encrypted by BCrypt.
    # Also adds methods to generate and clear a token, used to retrieve the record of a
    # user who has forgotten their password.
    #
    # Note that if a password isn't supplied when creating a user, the error will be on
    # the `password_digest` attribute.
    def authenticates
      send :include, InstanceMethodsOnActivation

      attr_reader    :password
      attr_protected :password_digest

      validates :username,        :presence => true, :uniqueness => true, :if => :should_authenticate?
      validates :password_digest, :presence => true, :if => :should_authenticate?

      scope :valid_token, lambda { |token| where("token = ? AND token_created_at > ?", token, 3.hours.ago) }

      instance_eval <<-END, __FILE__, __LINE__ + 1
        # Returns the user with the given <tt>username</tt> if the given password is
        # correct, and <tt>nil</tt> otherwise.
        def authenticate(username, plain_text_password)
          user = where(:username => username).first
          if user && user.has_matching_password?(plain_text_password)
            user
          else
            nil
          end
        end

        def find_by_salt(id, salt) # :nodoc:
          user = find_by_id id
          if user && user.has_matching_salt?(salt)
            user
          else
            nil
          end
        end

        # Instantiates a user suitable for user-activation.
        def new_for_activation(attributes = nil)
          user = new attributes
          # Satisfy username and password validations by setting to random values.
          begin
            user.username = SecureRandom.base64(10)
          end while exists?(:username => user.username)
          user.password = SecureRandom.base64(10)
          user
        end
      END
    end
  end

  module InstanceMethodsOnActivation
    # Override this in your model if you need to bypass the Quo Vadis validations.
    def should_authenticate?
      true
    end

    def password=(plain_text_password) # :nodoc:
      @password = plain_text_password
      unless @password.blank?
        self.password_digest = BCrypt::Password.create plain_text_password
      end
    end

    # Generates a unique, timestamped token.
    def generate_token # :nodoc:
      begin
        self.token = url_friendly_token
      end while self.class.exists?(:token => token)
      self.token_created_at = Time.now.utc
    end

    # Generates a unique, timestamped token which can be used in URLs, and
    # saves the record.  This is part of the forgotten-password workflow.
    def generate_token! # :nodoc:
      generate_token
      save
    end

    # Clears the user's timestamped token and saves the record.
    # This is part of the forgotten-password workflow.
    def clear_token # :nodoc:
      update_attributes :token => nil, :token_created_at => nil
    end

    # Returns true if the given <tt>plain_text_password</tt> is the user's
    # password, and false otherwise.
    def has_matching_password?(plain_text_password) # :nodoc:
      BCrypt::Password.new(password_digest) == plain_text_password
    end

    # Returns true if the given <tt>salt</tt> is the user's salt,
    # and false otherwise.
    def has_matching_salt?(salt) # :nodoc:
      password_salt == salt
    end

    def password_salt # :nodoc:
      BCrypt::Password.new(password_digest).salt
    end

    private

    def url_friendly_token # :nodoc:
      SecureRandom.base64(10).tr('+/=', 'xyz')
    end
  end

end
