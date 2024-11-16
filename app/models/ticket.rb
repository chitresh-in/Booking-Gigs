class Ticket < ApplicationRecord
  has_paper_trail
  acts_as_paranoid

  belongs_to :event
  belongs_to :booking, optional: true

  scope :available_for_booking, -> { where(saleable: true, booking_id: nil) }

  def self.in_queue_for_allocation_count(event)
    Rails.cache.read(event.tickets_on_hold_count_cache_key, raw: true).to_i
  end
end
