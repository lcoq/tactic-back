class Project < ApplicationRecord

  has_many :entries, dependent: :nullify

  validates :name, presence: true, uniqueness: { case_sensitive: false }

  scope :search_by_name, ->(query) { where('name ILIKE ?', "%#{query}%") }

end
