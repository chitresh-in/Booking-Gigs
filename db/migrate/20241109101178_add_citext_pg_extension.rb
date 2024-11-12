class AddCitextPgExtension < ActiveRecord::Migration[7.2]
  def change
    ActiveRecord::Base.connection.execute("CREATE EXTENSION IF NOT EXISTS citext")
  end
end
