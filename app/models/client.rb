class Client < ApplicationRecord

  has_many :projects, dependent: :nullify

  validates :name, presence: true, uniqueness: { case_sensitive: false }
end
