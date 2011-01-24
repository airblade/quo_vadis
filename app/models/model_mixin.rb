require 'bcrypt'

module ModelMixin

  def self.included(base)
    base.send :extend, ClassMethods
  end

  module ClassMethods
    def authenticates
      send :include, InstanceMethods

      validates      :password, :on => :create, :presence => true
      attr_protected :password_hash, :password_salt
      attr_accessor  :password
      before_save    :prepare_password

      validates      :username, :presence => true, :uniqueness => true

      instance_eval <<-END
        def authenticate(username, password)
          user = where(:username => username).first
          return user if user && user.matching_password?(password)
        end
      END
    end
  end

  module InstanceMethods
    def matching_password?(passwd)
      self.password_hash == encrypt_password(passwd)
    end

    private  # TODO: does this work once mixed in?

    def encrypt_password(passwd)
      BCrypt::Engine.hash_secret(passwd, password_salt)
    end

    def prepare_password
      unless password.blank?
        self.password_salt = BCrypt::Engine.generate_salt
        self.password_hash = encrypt_password(password)
      end
    end
  end

end
