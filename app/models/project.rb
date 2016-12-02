class Project < ApplicationRecord

  has_many :entries, dependent: :nullify

  validates :name, presence: true, uniqueness: { case_sensitive: false }

end
