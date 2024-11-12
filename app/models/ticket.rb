class Ticket < ApplicationRecord
  belongs_to :event
  belongs_to :booking

  scope :available_for_booking, -> { where(saleable: true, booking_id: nil) }
end
