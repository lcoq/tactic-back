module Teamwork
  class TimeEntryDestroyJob

    FAILURE_MESSAGE = <<-TXT
      A time entry with the following attributes cannot be deleted in Teamwork :

      %{attributes}

    TXT

    attr_reader :time_entry_id,
                :entry_title,
                :entry_duration,
                :entry_started_at

    def initialize(time_entry_id, entry_title: nil, entry_duration: nil, entry_started_at: nil)
      @time_entry_id = time_entry_id
      @entry_title = entry_title
      @entry_duration = entry_duration
      @entry_started_at = entry_started_at
    end

    def perform
      time_entry = TimeEntry.find_by(id: time_entry_id)
      return unless time_entry
      TimeEntrySynchronizer.destroy_time_entry! time_entry
    end

    def failure(job)
      time_entry = TimeEntry.find_by(id: time_entry_id)
      return unless time_entry
      domain = time_entry.domain
      user = domain && domain.user
      return unless user

      attributes = []
      if entry_title.present?
        attributes << entry_title
      end
      if entry_started_at.present? || entry_duration.present?
        attributes << [
          entry_started_at.try(:strftime, '%Y-%m-%d %H:%M'),
          entry_duration
        ].compact.join(" - ")
      end
      if entry_title.present? && entry_title.match(TimeEntrySynchronizer::TASK_REGEXP)
        task_id = $2
        attributes << "https://#{time_entry.domain.name}.teamwork.com/#/tasks/#{task_id}"
      end

      UserNotification.create(
        user: time_entry.domain.user,
        nature: :error,
        title: "Teamwork synchronization error",
        message: FAILURE_MESSAGE.gsub('%{attributes}', attributes.join("\n")),
      )
    end
  end
end
