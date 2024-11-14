class AddRequestedAtToBookings < ActiveRecord::Migration[7.2]
  def change
    add_column :bookings, :requested_at, :datetime
  end
end
