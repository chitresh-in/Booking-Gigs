class Ticket < ApplicationRecord
  has_paper_trail
  acts_as_paranoid

  belongs_to :event
  belongs_to :booking, optional: true

  scope :available_for_booking, -> { where(saleable: true, booking_id: nil) }

  def self.pending_for_allocation(event)
    pending_ticket_allocation_jobs = Sidekiq::Queue.new("ticket_allocation").select { |job| job.klass == "TicketAllocationJob" }
    booking_ids = pending_ticket_allocation_jobs.map { |job| job.args }.map { |args| args.first }
    Booking.where(id: booking_ids, event: event).pending.sum(:tickets_count)
  end
end
