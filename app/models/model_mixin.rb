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

      validates      :username,        :presence => true, :uniqueness => true
      validates      :password,        :on => :create, :presence => true
      validates      :password_digest, :presence => true

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

    def has_matching_password?(plain_text_password)
      BCrypt::Password.new(password_digest) == plain_text_password
    end
  end

end
