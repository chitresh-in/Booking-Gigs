module Event::SearchConcern
  extend ActiveSupport::Concern

  included do
    searchkick

    def search_data
      {
        title: title,
        description: rich_description.to_plain_text,
        category_name: category.name,
        venue_name: venue.name,
        host_name: host.name,
      }
    end
  
    scope :search_import, -> { 
      where(start_time: Time.current..)
      .published
      .includes(:category, :venue, :host, :poster_image_attachment, :rich_text_rich_description) 
    }
  
    def should_index?
      published? && start_time >= Time.current && poster_image.attached?
    end
  end
end
