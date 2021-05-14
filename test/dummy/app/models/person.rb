class Person < ApplicationRecord
  validates :username, presence: true, uniqueness: {case_sensitive: false}
  validates :email, presence: true, uniqueness: {case_sensitive: false}

  authenticates identifier: :username
end
