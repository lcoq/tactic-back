class User < ApplicationRecord

  has_many :sessions, dependent: :destroy
  has_many :entries, dependent: :destroy

  validates :name, presence: true, uniqueness: { case_sensitive: false }

  default_scope { order(:name) }

  def recent_entries
    entries.recent
  end
end
