json.extract! event, :id, :name, :description, :venue_id, :total_tickets, :max_tickets_per_user, :start_time, :created_at, :updated_at
json.url event_url(event, format: :json)
