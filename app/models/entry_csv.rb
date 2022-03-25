require 'csv'

class EntryCsv
  attr_reader :collection, :rounded

  def initialize(collection, rounded: false)
    @collection = collection
    @rounded = rounded
  end

  def generate
    CSV.generate do |csv|
      csv << headers
      collection.each do |entry|
        csv << line(entry)
      end
    end
  end

  def headers
    [
      'user',
      'client',
      'project',
      'title',
      'duration',
      'date',
      'start time',
      'end time'
    ]
  end

  def line(entry)
    [
      entry.user.name,
      entry.project.try(:client).try(:name),
      entry.project.try(:name),
      entry.title,
      rounded ? format_duration(entry.rounded_duration) : format_duration(entry.duration),
      rounded ? format_date(entry.rounded_started_at) : format_date(entry.started_at),
      rounded ? format_time(entry.rounded_started_at) : format_time(entry.started_at),
      rounded ? format_time(entry.rounded_stopped_at) : format_time(entry.stopped_at)
    ]
  end

  def format_duration(duration)
    total = duration.seconds
    hours = (total / 1.hour).truncate
    minutes = ((total - hours.hours) / 1.minute).truncate
    # seconds = ((total - hours.hours - minutes.minutes) / 1.second).truncate
    value_format = "%02.f"
    [ value_format % hours, value_format % minutes ].join(':')
  end

  def format_date(datetime)
    datetime.strftime "%d/%m/%Y"
  end

  def format_time(datetime)
    datetime.strftime "%H:%M"
  end
end
