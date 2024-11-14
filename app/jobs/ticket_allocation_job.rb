class TicketAllocationJob
  include Sidekiq::Job

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

      if available_tickets.count < tickets_count
        raise ActiveRecord::Rollback
      end

      available_tickets.update_all(booking_id: booking.id)
    end
  end
end
