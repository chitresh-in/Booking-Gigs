class CreateEvents < ActiveRecord::Migration[7.2]
  def change
    create_table :events do |t|
      t.string :title, null: false
      t.text :description
      t.integer :status, null: false, default: 0
      t.integer :total_tickets
      t.integer :max_tickets_per_user
      t.datetime :start_time, null: false
      t.datetime :end_time, null: false
      t.datetime :booking_start_time, null: false
      t.datetime :booking_end_time, null: false

      t.references :category, null: false, foreign_key: true
      t.references :venue, null: false, foreign_key: true
      t.references :host, null: false, foreign_key: { to_table: :users }

      t.timestamps
      t.datetime :deleted_at
    end
  end
end
