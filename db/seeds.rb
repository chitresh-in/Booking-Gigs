# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

# Create 10 users
10.times do |i|
  user = User.find_or_create_by(email: "test#{i}@test.com") do |new_user|
    new_user.name = Faker::Name.name
    new_user.password = "password"
  end
end

# Create 10 categories
10.times do |i|
  Category.find_or_create_by(name: Faker::Book.genre.titleize)
end

# Create 10 venues
10.times do |i|
  Venue.find_or_create_by(name: Faker::Address.street_address)
end

# Create 10 events
require 'open-uri'
10.times do |i|
    event = Event.find_or_create_by!(title: Faker::Book.title) do |event|
      # Basic attributes
      event.description = Faker::Lorem.sentence
      event.rich_description = ActionText::Content.new(Faker::Lorem.paragraphs(number: 3).join('<br><br>'))
      event.total_tickets = rand(50..5000)
      event.max_tickets_per_user = rand(1..5)
      event.category = Category.all.sample
      event.venue = Venue.all.sample
      event.host = User.all.sample

      event.booking_start_time = Faker::Time.between(from: DateTime.now + 5.minutes, to: DateTime.now + 2.days)
      event.booking_end_time = event.booking_start_time + rand(2..14).days
      event.start_time = event.booking_end_time + 1.day
      event.end_time = event.start_time + rand(2..8).hours  
    end
    
    next if event.poster_image.attached?

    downloaded_image = URI.open("https://picsum.photos/600/600")
    event.poster_image.attach(
      io: downloaded_image,
      filename: "event_poster_#{i}.jpg",
      content_type: 'image/jpeg'
    )
    event.update(status: :published)
  end
