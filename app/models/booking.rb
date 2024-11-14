class Booking < ApplicationRecord
  has_paper_trail
  acts_as_paranoid

  enum :status, { pending: 0, confirmed: 1, failed: 2, cancelled: 3 }
  # TODO: Add AASM to handle status transitions and guards

  belongs_to :user
  belongs_to :event

  has_many :tickets, dependent: :nullify

  validates :user, :event, :requested_at, :tickets_count, presence: true

  validate :ensure_booking_within_open_window
  validate :ensure_no_other_pending_bookings
  validate :ensure_user_ticket_limit
  
  private 

  def ensure_booking_within_open_window
    return if requested_at.blank?

    if requested_at < event.booking_start_time
      errors.add(:base, "Booking is not yet open for this event")
    elsif requested_at > event.booking_end_time
      errors.add(:base, "Booking has closed for this event")
    end
  end

  def ensure_no_other_pending_bookings
    return unless pending?

    existing_pending_bookings = user.bookings.where(event: event, status: :pending).where.not(id: id)
    errors.add(:base, "You already have a pending booking for this event") if existing_pending_bookings.exists?
  end

  def ensure_user_ticket_limit
    return unless event&.max_tickets_per_user
    
    total_user_tickets = user.bookings
      .where(event: event)
      .where.not(id: id)
      .sum(:tickets_count)
      
    if total_user_tickets + tickets_count > event.max_tickets_per_user
      errors.add(:tickets_count, "exceeds the limit of #{event.max_tickets_per_user} tickets per user")
    end
  end
end
