class Ticket < ApplicationRecord
  has_paper_trail
  acts_as_paranoid

  belongs_to :event
  belongs_to :booking, optional: true

  scope :available_for_booking, -> { where(saleable: true, booking_id: nil) }

  def self.pending_for_allocation(event)
    # Get all booking ids from the queue
    ticket_allocation_jobs_in_queue = Sidekiq::Queue.new("ticket_allocation").select { |job| job.klass == "TicketAllocationJob" }
    booking_ids = ticket_allocation_jobs_in_queue.map { |job| job.args }.map { |args| args.first }

    # Get all booking ids from currently running jobs
    workers = Sidekiq::Workers.new
    workers.each do |process_id, thread_id, work|
      if work['queue'] == 'ticket_allocation' && JSON.parse(work['payload'])['class'] == 'TicketAllocationJob'
        booking_ids << JSON.parse(work['payload'])['args'].first
      end
    end
    Booking.where(id: booking_ids.uniq, event: event).pending.sum(:tickets_count)
  end
end
