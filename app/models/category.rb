class Category < ApplicationRecord
    has_paper_trail
    acts_as_paranoid
    
    validates :name, presence: true, uniqueness: true

    after_commit :expire_options_for_select_cache

    def self.options_for_select
        Rails.cache.fetch("category_options_for_select", expires_in: 30.days) do
            Category.order(:name).map { |category| [category.name, category.id] }
        end
    end

    private

    def expire_options_for_select_cache
        Rails.cache.delete("category_options_for_select")
    end
end
