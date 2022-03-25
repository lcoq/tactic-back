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

  scope :filter_with, ->(h) {
    scoped = since(h[:since]).before(h[:before])
    scoped = scoped.where(user_id: h[:user_ids]) if h[:user_ids]
    scoped = scoped.where(project_id: h[:project_ids]) if h[:project_ids]
    scoped = scoped.for_query(h[:query]) if h[:query]
    scoped
  }

  scope :for_query, ->(query) {
    or_words = query.split(/\s*\|\s*/).map { |word| "%#{word}%" }
    clause = or_words.length.times.map { "title ILIKE ?" }.join(" OR ")
    where(clause, *or_words)
  }

  def started_at=(*_)
    super
    super started_at.change(usec: 0) if started_at
  end

  def stopped_at=(*_)
    super
    super stopped_at.change(usec: 0) if stopped_at
  end

  def duration
    return if running?
    stopped_at - started_at
  end

  def rounded_started_at(round_minutes: default_round_minutes, nearest: default_round_nearest)
    return unless started_at.present?
    round_minutes = round_minutes.minutes
    timestamp = started_at.to_i
    rounded = timestamp - (timestamp % round_minutes)
    if nearest && timestamp % round_minutes >= (round_minutes / 2)
      rounded += round_minutes
    elsif !nearest && (timestamp - (timestamp % 60)) % round_minutes != 0
      rounded += round_minutes
    end
    Time.zone.at(rounded)
  end

  def rounded_stopped_at(round_minutes: default_round_minutes, nearest: default_round_nearest)
    return if running?
    start = rounded_started_at(round_minutes: round_minutes, nearest: nearest)
    duration = rounded_duration(round_minutes: round_minutes, nearest: nearest).seconds
    start + duration
  end

  def rounded_duration(round_minutes: default_round_minutes, nearest: default_round_nearest)
    return unless duration
    seconds = duration.seconds
    minutes = (seconds / 1.minute).truncate
    rounded = minutes
    rounded += round_minutes if nearest && (seconds % 60) >= 30
    if minutes % round_minutes != 0
      rounded += (round_minutes - (minutes % round_minutes))
    end
    rounded.minutes.to_i
  end

  def rounded_duration(round_minutes: default_round_minutes, nearest: default_round_nearest)
    return unless duration
    round_minutes = round_minutes.minutes
    rounded = duration - (duration % round_minutes)
    if nearest && duration % round_minutes >= (round_minutes / 2)
      rounded += round_minutes
    elsif !nearest && (duration - (duration % 60)) % round_minutes != 0
      rounded += round_minutes
    end
    rounded.to_i
  end

  def stopped?
    stopped_at.present?
  end

  def running?
    !stopped?
  end

  private

  def default_round_minutes
    5
  end

  def default_round_nearest
    false
  end

  def stopped_at_is_after_started_at
    if started_at && stopped_at && stopped_at < started_at
      errors.add(:stopped_at, "cannot stop before the start")
    end
  end
end
