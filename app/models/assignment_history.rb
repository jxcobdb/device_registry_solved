class AssignmentHistory < ApplicationRecord
  belongs_to :user
  belongs_to :device

  enum action: {
    assigned: "assigned",
    returned: "returned"
  }
end
