class CreateCategories < ActiveRecord::Migration[7.2]
  def change
    create_table :categories do |t|
      t.citext :name, null: false
      
      t.timestamps
      t.datetime :deleted_at
    end
    add_index :categories, :name, unique: true
  end
end
