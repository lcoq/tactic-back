class Client < ApplicationRecord

  has_many :projects, dependent: :nullify

  validates :name, presence: true, uniqueness: { case_sensitive: false }

  scope :active, -> { where(archived: false) }

  def archive
    self.archived = true
    projects.update_all archived: true
    save
  end
end
