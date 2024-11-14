class Event < ApplicationRecord
  include Event::SearchConcern
  
  has_paper_trail
  acts_as_paranoid

  enum :status, { draft: 0, published: 1, cancelled: 2}
  # TODO: Add AASM to handle status transitions and guards

  belongs_to :category
  belongs_to :venue
  belongs_to :host, class_name: "User"

  has_one_attached :poster_image
  has_rich_text :rich_description

  has_many :tickets, dependent: :destroy
  has_many :bookings, dependent: :restrict_with_exception
  has_many :users, through: :bookings
  
  validates :title, :start_time, :end_time, :booking_start_time, :booking_end_time, 
    :category, :venue, presence: true
  validates :poster_image, attached: true, if: -> { published? }

  validate :booking_start_time_must_be_future
  validate :booking_end_time_must_be_after_booking_start_time
  validate :event_start_time_must_be_after_booking_end_time
  validate :event_end_time_must_be_after_event_start_time
  # TODO: Add validation to ensure no changes are made to published events

  after_create :create_tickets, if: -> { saved_change_to_status?(from: "draft", to: "published") }

  scope :order_by_booking_status, -> { 
    order(Arel.sql("CASE 
                      WHEN booking_start_time <= '#{Time.current}' AND booking_end_time >= '#{Time.current}' THEN 0 
                      ELSE 1 
                    END, 
                    booking_start_time, 
                    start_time")) 
  }

  def has_unlimited_tickets?
    total_tickets.nil?
  end

  def booking_open?
    Time.current >= booking_start_time && Time.current <= booking_end_time
  end

  def booking_ended?
    Time.current > booking_end_time
  end
  
  private
  
  def booking_start_time_must_be_future
    if booking_start_time.present? && booking_start_time < Time.current
      errors.add(:booking_start_time, "must be in the future")
    end
  end

  def booking_end_time_must_be_after_booking_start_time
    if booking_end_time <= booking_start_time
      errors.add(:booking_end_time, "must be after booking start time")
    end
  end

  def event_start_time_must_be_after_booking_end_time
    if start_time <= booking_end_time
      errors.add(:start_time, "must be after booking start and end time")
    end
  end

  def event_end_time_must_be_after_event_start_time
    if end_time <= start_time
      errors.add(:end_time, "must be after event start time")
    end
  end

  def create_tickets
    Ticket.create!([{event_id: id}] * total_tickets) unless has_unlimited_tickets?
  end
end
