class Booking < ApplicationRecord
  enum :status, { pending: 0, confirmed: 1, failed: 2, cancelled: 3 }

  belongs_to :user
  
  has_many :tickets, dependent: :nullify
end
