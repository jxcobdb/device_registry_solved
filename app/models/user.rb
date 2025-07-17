class User < ApplicationRecord
  has_many :api_keys, as: :bearer
  has_secure_password
  has_many :devices
  has_many :assignment_histories
end
