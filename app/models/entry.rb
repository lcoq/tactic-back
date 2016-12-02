class Entry < ApplicationRecord
  belongs_to :user
  belongs_to :project, optional: true

  validates :started_at, presence: true
  validates :stopped_at, presence: true
  validate :stopped_at_is_after_started_at

  scope :since, ->(date) { where('started_at > ?', date) }
  scope :recent, -> { since(Time.zone.now - 1.month) }

  private

  def stopped_at_is_after_started_at
    if started_at && stopped_at && stopped_at < started_at
      errors.add(:stopped_at, "cannot stop before the start")
    end
  end
end
