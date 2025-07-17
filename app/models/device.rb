class Device < ApplicationRecord
  belongs_to :user, optional: true
  has_many :assignment_histories
end
