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

    def failure(job)
      entry = Entry.find_by(id: entry_id)
      user = User.find_by(id: user_id)
      return unless entry && user
      UserNotification.create(
        user: user,
        nature: :error,
        title: "Teamwork synchronization error",
        message: "The following entry cannot be saved in Teamwork, please make sure the entered ID matches the entry.",
        resource: entry,
      )
    end

  end
end
