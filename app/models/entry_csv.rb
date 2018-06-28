require 'csv'

class EntryCSV
  attr_reader :collection

  def initialize(collection)
    @collection = collection
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
      'started at',
      'stopped at'
    ]
  end

  def line(entry)
    [
      entry.user.name,
      entry.project.try(:client).try(:name),
      entry.project.try(:name),
      entry.title,
      format_duration(entry.duration),
      format_datetime(entry.started_at),
      format_datetime(entry.stopped_at)
    ]
  end

  def format_duration(duration)
    total = duration.seconds
    hours = (total / 1.hour).truncate
    minutes = ((total - hours.hours) / 1.minute).truncate
    seconds = ((total - hours.hours - minutes.minutes) / 1.second).truncate
    value_format = "%02.f"
    formatted_parts = [ value_format % minutes, value_format % seconds ]
    formatted_parts.unshift(value_format % hours) if hours > 0
    formatted_parts.join(':')
  end

  def format_datetime(datetime)
    datetime.strftime "%d/%m/%Y %H:%m:%S"
  end
end
