class EventsController < ApplicationController
  before_action :set_event, only: %i[ show edit update]
  before_action :authenticate_user!, only: %i[ new edit update]

  # GET /events or /events.json
  def index    
    if params[:search].present?
      @events = Event.search(params[:search])
    else
      @events = Event.published.order_by_booking_status
    end
    @events = @events.includes(:host, :venue, :category, [poster_image_attachment: :blob])
    # TODO: Add pagination
  end

  # GET /events/1 or /events/1.json
  def show; end

  # GET /events/new
  def new
    @event = Event.new
  end

  # GET /events/1/edit
  def edit
  end

  # POST /events or /events.json
  def create
    @event = Event.new(event_params)
    @event.host = current_user
    @event.status = :published
    respond_to do |format|
      if @event.save
        format.html { redirect_to @event, notice: "Event was successfully created." }
        format.json { render :show, status: :created, location: @event }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @event.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /events/1 or /events/1.json
  def update
    respond_to do |format|
      if @event.update(event_params)
        format.html { redirect_to @event, notice: "Event was successfully updated." }
        format.json { render :show, status: :ok, location: @event }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @event.errors, status: :unprocessable_entity }
      end
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_event
      @event = Event.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def event_params
      params.require(:event).permit(:title, :rich_description, :total_tickets, :max_tickets_per_user, 
        :start_time, :end_time, :booking_start_time, :booking_end_time, :category_id, :venue_id, :host_id, :poster_image
      )
    end
end
