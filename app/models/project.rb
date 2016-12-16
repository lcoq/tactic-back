class Project < ApplicationRecord

  belongs_to :client, optional: true

  has_many :entries, dependent: :nullify

  validates :name, presence: true, uniqueness: { case_sensitive: false }

  scope :search_by_name, ->(query) { where('name ILIKE ?', "%#{query}%") }
  scope :active, -> { where(archived: false) }

  def archive
    self.archived = true
    save
  end
end
