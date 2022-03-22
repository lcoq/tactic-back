module Teamwork
  class EntryUpdater

    def self.use_for?(entry, current_user:)
      ::UserConfig.find_for_user(current_user, 'teamwork').value
    end

    attr_reader :entry,
                :current_user

    def initialize(entry, current_user:)
      @entry = entry
      @current_user = current_user
    end

    def update(attributes)
      entry.assign_attributes attributes

      if entry.title_changed?
        replace_teamwork_url_from_title
      end

      if entry.save
        synchronize_teamwork_time
        true
      else
        false
      end
    end

    def destroy
      if entry.destroy
        destroy_teamwork_time
        true
      else
        false
      end
    end

    private

    def replace_teamwork_url_from_title
      replace_task_url = Teamwork::UserConfig.find_for_user(current_user, 'teamwork-task-url-replace').value
      domains = Teamwork::Domain.where(user: current_user)
      entry.title = EntryTitleBuilder.build(
        entry.title,
        domains: domains,
        replace_task_url: replace_task_url
      )
    end

    def synchronize_teamwork_time
      return unless Teamwork::UserConfig.find_for_user(current_user, 'teamwork-task-time-entry-synchronization').value
      TimeEntrySynchronizer.synchronize entry, user: current_user
    end

    def destroy_teamwork_time
      return unless Teamwork::UserConfig.find_for_user(current_user, 'teamwork-task-time-entry-synchronization').value
      TimeEntrySynchronizer.destroy entry, user: current_user
    end

  end
end
