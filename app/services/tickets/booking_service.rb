module Tickets
  class BookingService
    def initialize(event, user)
      @event = event
      @user = user
    end
  
    def book(tickets_count)
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
          return { success: false, error: booking.errors.full_messages }
        end
      end

      return { success: false, error: 'Tickets sold out' } if @event.tickets.available_for_booking.count < tickets_count

      if booking.save
        TicketAllocationJob.perform_async(booking.id, tickets_count)
        return { success: true, booking_id: booking.id }
      else
        return { success: false, error: booking.errors.full_messages }
      end
    end
  end
end
