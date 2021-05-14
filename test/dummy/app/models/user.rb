class User < ApplicationRecord
  validates :name, presence: true
  validates :email, presence: true, uniqueness: {case_sensitive: false}

  authenticates
end
