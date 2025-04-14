class User < ApplicationRecord
  validates :name, presence: true
  validates :email, presence: true, uniqueness: {case_sensitive: false}

  normalizes :email, with: -> { _1.strip.downcase }

  authenticates
end
