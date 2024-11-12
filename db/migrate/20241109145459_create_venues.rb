class CreateVenues < ActiveRecord::Migration[7.2]
  def change
    create_table :venues do |t|
      t.citext :name, null: false

      t.timestamps
      t.datetime :deleted_at
    end

    add_index :venues, :name, unique: true
  end
end
