class BookingsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_booking, only: %i[show cancel]
  before_action :set_event, only: %i[create]
  def index
    @bookings = current_user.bookings.order(created_at: :desc)
  end

  def show
  end

  def create
    tickets_booking_service = Tickets::BookingService.new(@event, current_user)
    result = tickets_booking_service.book(booking_params[:tickets_count])
    return redirect_to booking_path(result[:booking_id]) if result[:success]

    redirect_to event_path(booking_params[:event_id]), alert: result[:error]
  end

  # TODO: Implement cancel action
  def cancel
    tickets_cancellation_service = Tickets::CancellationService.new(@booking)
    result = tickets_cancellation_service.cancel
    return redirect_to booking_path(@booking) if result[:success]

    redirect_to booking_path(@booking), alert: result[:error]
  end

  private

  def booking_params
    params.require(:booking).permit(:tickets_count, :event_id)
  end

  def set_event
    @event = Event.find(booking_params[:event_id])
  end

  def set_booking
    @booking = Booking.find(params[:id])
  end
end
