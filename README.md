<p align="center">
  <img src="https://github.com/user-attachments/assets/968e594e-d43a-4d9d-862f-1e04b1fd1cf8" alt="logo" width="100">
</p>
<h1 align="center">Booking Gigs</h1>
<p align="center">Discover, Post, and Book Your Next Big Gig!</p>

## Tech Stack & Dependencies

### Core
- <img src="https://cdn.jsdelivr.net/gh/devicons/devicon/icons/ruby/ruby-original.svg" width="20" height="20" /> Ruby 3.3.5
- <img src="https://cdn.jsdelivr.net/gh/devicons/devicon/icons/rails/rails-plain.svg" width="20" height="20" /> Rails 7.2.1
- <img src="https://cdn.jsdelivr.net/gh/devicons/devicon/icons/postgresql/postgresql-original.svg" width="20" height="20" /> PostgreSQL
- <img src="https://cdn.jsdelivr.net/gh/devicons/devicon/icons/redis/redis-original.svg" width="20" height="20" /> Redis
- <img src="https://cdn.jsdelivr.net/gh/devicons/devicon/icons/elasticsearch/elasticsearch-original.svg" width="20" height="20" /> Elasticsearch
- ⚡ Sidekiq for background jobs

### Key Gems
- [`devise`](https://github.com/heartcombo/devise) - Authentication
- [`paper_trail`](https://github.com/paper-trail-gem/paper_trail) - Versioning
- [`paranoia`](https://github.com/rubysherpas/paranoia) - Soft deletes
- [`searchkick`](https://github.com/ankane/searchkick) - Search functionality
- [`elasticsearch`](https://github.com/elastic/elasticsearch-ruby) - Search functionality
- [`local_time`](https://github.com/basecamp/local_time) - Client timezone support
- [`active_storage_validations`](https://github.com/igorkasyanchuk/active_storage_validations) - Validations for Active Storage
- [`faker`](https://github.com/faker-ruby/faker) - Fake data generator
- [`rails-erd`](https://github.com/voormedia/rails-erd) - Generate Entity-Relationship Diagrams

### Dev Gems (Planned)
- [`rubocop`](https://github.com/rubocop/rubocop) - Ruby code style checking
- [`overcommit`](https://github.com/brigade/overcommit) - Git hook manager
- [`bullet`](https://github.com/flyerhzm/bullet) - Detect N+1 queries
- [`annotate`](https://github.com/ctran/annotate_models) - Add comments to model files
- [`better_errors`](https://github.com/charliesome/better_errors) - Better error page


## Database Schema
<img width="1000" alt="Screenshot 2024-11-15 at 12 01 49 PM" src="https://github.com/user-attachments/assets/04fe2e54-6395-46c9-93e7-5f67b2ef195f">


## User Actions
| Action | Screenshot |
|--------|------------|
| 1. Browse and search for available gigs | <img width="1000" alt="1  Homepage" src="https://github.com/user-attachments/assets/029f2a03-b17a-4dea-9600-e0fbf44b4829"> |
| 2. View details for a gig | <img width="1000" alt="2  Event details page  for non logged in user" src="https://github.com/user-attachments/assets/dae28a97-3a48-4d33-a64c-c510b436cbc2"> |
| 3. Login to book a gig | <img width="1000" alt="3  Login Screen" src="https://github.com/user-attachments/assets/5374f620-0a0a-454c-ade9-7e5d0cb3429a"> |
| 4. View details for a gig as a logged in user | <img width="1000" alt="4  Details page for logged in user" src="https://github.com/user-attachments/assets/31e79a9d-b107-486d-b36d-37a37b783d56"> |
| 5. View your bookings | <img width="1000" alt="5  Bookings" src="https://github.com/user-attachments/assets/a99877b4-88bc-475c-9fdd-95e710335f15"> |
| 6. Create a new gig | <img width="1000" alt="6  Create new event" src="https://github.com/user-attachments/assets/1073275f-a470-4ca7-9fba-074f2eb753e4"> |


## Scope of improvements
1. Implement rate limiting for booking tickets endpoint.
2. Add choke point for booking tickets so that at a given time only a certain number of users can attempt to book tickets.
3. Add reCAPTCHA before user can proceed with booking, using [`recaptcha`](https://github.com/ambethia/recaptcha) gem.
4. Leverage CDN to cache static assets and non frequently changing pages like event details page to reduce load on server.
5. Add [`aasm`](https://github.com/aasm/aasm) gem to handle event and booking status transitions and guards.
6. Add validations to ensure no changes are made to published events.
7. Show number of people attending the event on the event details page.
8. Show number of users currently viewing the event on the event details page.
9. Implement server-sent events to update booking status in realtime.


## Test Plan
### 1. User tries to book an event with unlimited tickets.
- Create an event with unlimited tickets(tickets_count = nil).
- Create a user.
- User tries to book 5 tickets.

#### a. Maximum allowed tickets per user is not exceeded:
- Expected result: Booking should be successful and move to confirmed status.

#### b. Maximum allowed tickets per user is exceeded:
- Expected result: Booking should fail with "Maximum allowed tickets per user exceeded" error.

#### c. User has previous confirmed booking for the event:
- If total tickets booked by user is less than or equal to maximum allowed tickets per user.
- Expected result: Booking should be successful and move to confirmed status.

- If total tickets booked by user is greater than maximum allowed tickets per user.
- Expected result: Booking should fail with "Maximum allowed tickets per user exceeded" error.

#### d. User has previous pending booking for the event:
- Expected result: Booking should fail with "You already have a pending booking for this event" error.

### 2. User tries to book more tickets than available.
- Create an event with 100 tickets.
- Create a user.
- Create bookings for 100 tickets.
- User tries to book 5 tickets.

- Expected result: Booking should fail with "Tickets sold out" error.

### 3. Multiple users attempt to book the same event with limited tickets.
- Create an event with 100 tickets.
- Create 30 users.
- Use threads to have each user attempt to book 5 tickets concurrently.

- Expected result: Only 20 users should get booking with confirmed status and 5 tickets each. The rest should get a "Tickets sold out" error.
- In case some of the other 10 users are able to make booking, it should move to the failed status.
