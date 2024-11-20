class TicketAllocationJob
  include Sidekiq::Job
  sidekiq_options queue: "ticket_allocation"

  def perform(booking_id)
    booking = Booking.lock.find_by(id: booking_id)
    return if booking.nil?

    event = booking.event
    return if event.nil?

    ActiveRecord::Base.transaction do
      available_ticket_ids = event.tickets.available_for_booking.lock("FOR UPDATE SKIP LOCKED").limit(booking.tickets_count).ids

      if available_ticket_ids.length < booking.tickets_count
        booking.update(status: :failed)
      else
        Ticket.where(id: available_ticket_ids).update_all(booking_id: booking.id)
        booking.update(status: :confirmed, confirmed_at: Time.current)
      end
      Rails.cache.decrement(event.tickets_on_hold_count_cache_key, booking.tickets_count)
    end
  end
end
