module Tickets
  class CancellationService
    def initialize(booking)
      @booking = booking
    end

    def cancel
      return { success: false, error: 'Booking is not cancellable' } unless @booking.cancellable?

      ActiveRecord::Base.transaction do
        @booking.tickets.update_all(booking_id: nil)
        @booking.update!(status: :cancelled)
      rescue ActiveRecord::RecordInvalid => e
        return { success: false, error: e.message }
      end

      { success: true }
    end
  end
end
