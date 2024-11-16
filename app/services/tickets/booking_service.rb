module Tickets
  class BookingService
    def initialize(event, user)
      @event = event
      @user = user
    end
  
    def book(tickets_count)
      tickets_count = tickets_count.to_i
      if tickets_count > @event.tickets.available_for_booking.count - Ticket.in_queue_for_allocation_count(@event)
        return { success: false, error: 'Tickets sold out' }
      end

      booking = Booking.new(
        event: @event,
        user: @user,
        tickets_count: tickets_count.to_i,
        requested_at: Time.current
      )

      if @event.has_unlimited_tickets?
        booking.status = :confirmed
        booking.confirmed_at = Time.current

        if booking.save
          return { success: true, booking_id: booking.id }
        else
          return { success: false, error: booking.errors.full_messages.join(', ') }
        end
      end

      if booking.save
        Rails.cache.increment(@event.tickets_on_hold_count_cache_key, booking.tickets_count)
        TicketAllocationJob.perform_async(booking.id)
        return { success: true, booking_id: booking.id }
      else
        return { success: false, error: booking.errors.full_messages.join(', ') }
      end
    end
  end
end
