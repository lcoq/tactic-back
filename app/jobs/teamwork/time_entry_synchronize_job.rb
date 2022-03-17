module Teamwork
  class TimeEntrySynchronizeJob

    attr_reader :entry_id,
                :user_id

    def initialize(entry_id, user_id)
      @entry_id = entry_id
      @user_id = user_id
    end

    def perform
      entry = Entry.find_by(id: entry_id)
      user = User.find_by(id: user_id)
      return unless entry && user
      TimeEntrySynchronizer.synchronize! entry, user: user
    end

  end
end
