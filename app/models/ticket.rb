class Ticket < ApplicationRecord
  has_paper_trail
  acts_as_paranoid

  belongs_to :event
  belongs_to :booking

  scope :available_for_booking, -> { where(saleable: true, booking_id: nil) }
end
