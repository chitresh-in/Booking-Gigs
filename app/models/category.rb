class Category < ApplicationRecord
    has_paper_trail
    acts_as_paranoid
    
    validates :name, presence: true, uniqueness: true
end
