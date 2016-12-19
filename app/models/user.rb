class User < ApplicationRecord

  has_many :sessions, dependent: :destroy
  has_many :entries, dependent: :destroy do
    def running
      where(stopped_at: nil).take
    end
  end

  validates :name, presence: true, uniqueness: { case_sensitive: false }

  default_scope { order(:name) }

  def recent_entries
    entries.recent
  end

  def running_entry
    entries.running
  end
end
