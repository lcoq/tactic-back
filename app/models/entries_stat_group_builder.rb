class EntriesStatGroupBuilder

  TIME_ZONE_ID = Time.zone.tzinfo.identifier

  class << self
    def daily(filters)
      new.daily filters
    end

    def monthly(filters)
      new.monthly filters
    end
  end

  def daily(filters)
    entries_scope = Entry.filter(filters)
    EntriesStatGroup.new(
      id: build_id(filters, "%Y/%m/%d"),
      title: build_title("Hours per day", filters),
      nature: 'hour/day',
      entries_stats: build_entries_stats('day', entries_scope)
    )
  end

  def monthly(filters)
    entries_scope = Entry.filter(filters)
    EntriesStatGroup.new(
      id: build_id(filters, "%Y/%m"),
      title: build_title("Hours per month", filters),
      nature: 'hour/month',
      entries_stats: build_entries_stats('month', entries_scope)
    )
  end

  private

  def build_title(title, filters)
    format = "%-d %B %Y"
    since = filters[:since].strftime(format)
    before = filters[:before].strftime(format)
    "#{title} from #{since} to #{before}"
  end

  def build_id(filters, format)
    since = filters[:since].strftime(format)
    before = filters[:before].strftime(format)
    "#{since}-#{before}"
  end

  def build_entries_stats(trunc_type, entries_scope)
    date_sql = "DATE_TRUNC('#{trunc_type}', entries.started_at AT TIME ZONE '#{TIME_ZONE_ID}') AT TIME ZONE '#{TIME_ZONE_ID}' AS date"
    duration_sql = "SUM(EXTRACT(EPOCH FROM (entries.stopped_at - entries.started_at))) AS duration"
    entries_scope = entries_scope.stopped.select(duration_sql, date_sql).group('date').order('date')
    Entry.connection.select_all(entries_scope.to_sql).map do |line|
      date = line['date'].to_date
      EntriesStat.new id: date.to_s, date: date, duration: line['duration']
    end
  end

end
