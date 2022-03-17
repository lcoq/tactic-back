module Teamwork
  class TimeEntryDestroyJob

    attr_reader :time_entry_id

    def initialize(time_entry_id)
      @time_entry_id = time_entry_id
    end

    def perform
      time_entry = TimeEntry.find_by(id: time_entry_id)
      return unless time_entry
      TimeEntrySynchronizer.destroy_time_entry! time_entry
    end
  end
end
