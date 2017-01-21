class Entry < ApplicationRecord
  belongs_to :user
  belongs_to :project, optional: true

  validates :started_at, presence: true
  validates :stopped_at, uniqueness: { scope: :user }, if: :running?
  validate :stopped_at_is_after_started_at

  scope :before, ->(date) { where('started_at <= ?', date) }
  scope :since, ->(date) { where('started_at > ?', date) }
  scope :recent, -> { since(Time.zone.now - 1.month) }
  scope :in_current_week, -> { since(Time.zone.now.beginning_of_week) }
  scope :in_current_month, -> { since(Time.zone.now.beginning_of_month) }
  scope :stopped, -> { where.not(stopped_at: nil) }

  scope :filter, ->(h) {
    scoped = since(h[:since]).before(h[:before])
    scoped = scoped.where(user_id: h[:user_ids]) if h[:user_ids]
    scoped = scoped.where(project_id: h[:project_ids]) if h[:project_ids]
    scoped
  }

  def started_at=(*_)
    super
    super started_at.change(usec: 0) if started_at
  end

  def stopped_at=(*_)
    super
    super stopped_at.change(usec: 0) if stopped_at
  end

  private

  def running?
    stopped_at.blank?
  end

  def stopped_at_is_after_started_at
    if started_at && stopped_at && stopped_at < started_at
      errors.add(:stopped_at, "cannot stop before the start")
    end
  end
end
