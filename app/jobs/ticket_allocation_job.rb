class TicketAllocationJob
  include Sidekiq::Job
  sidekiq_options queue: "ticket_allocation"

  def perform(booking_id)
    booking = Booking.find_by(id: booking_id)
    return if booking.nil?

    event = booking.event
    return if event.nil?

    ActiveRecord::Base.transaction do
      available_tickets = event.tickets
        .available_for_booking
        .lock("FOR UPDATE SKIP LOCKED")
        .limit(booking.tickets_count)

      if available_tickets.count < booking.tickets_count
        booking.update(status: :failed)
        return
      end

      available_tickets.update_all(booking_id: booking.id)
      booking.update(status: :confirmed, confirmed_at: Time.current)
    end
  end
end
