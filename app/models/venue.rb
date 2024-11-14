class Venue < ApplicationRecord
    has_paper_trail
    acts_as_paranoid

    after_commit :expire_options_for_select_cache

    def self.options_for_select
        Rails.cache.fetch("venue_options_for_select", expires_in: 30.days) do
            Venue.order(:name).map { |venue| [venue.name, venue.id] }
        end
    end

    private

    def expire_options_for_select_cache
        Rails.cache.delete("venue_options_for_select")
    end
end
