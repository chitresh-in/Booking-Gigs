class CreateTickets < ActiveRecord::Migration[7.2]
  def change
    create_table :tickets do |t|
      t.references :event, null: false, foreign_key: true
      t.references :booking, foreign_key: true
      t.boolean :saleable, null: false, default: true
      t.datetime :alloted_at

      t.timestamps
    end
  end
end
