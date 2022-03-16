module Teamwork
  class TimeEntrySynchronizer

    TASK_REGEXP = /\A\[([^\/]+)\/(\d+)\]\s*(.*)\Z/

    class << self
      def synchronize(*args)
        new(*args).synchronize
      end

      def destroy(*args)
        new(*args).destroy
      end
    end

    attr_reader :entry,
                :user,
                :time_entry,
                :rounding

    def initialize(entry, user:)
      @entry = entry
      @user = user
    end

    def synchronize
      load_time_entry
      @rounding = Teamwork::UserConfig.find_for_user(user, 'teamwork-task-time-entry-rounding').value

      if entry.title && entry.title.match(TASK_REGEXP) && entry.stopped? && duration > 0
        domain_alias, task_id, description = [ $1, $2, $3 ]
        create_or_update_time domain_alias, task_id, description
      elsif time_entry
        delete_time_entry
      end
    end

    def destroy
      load_time_entry
      if time_entry
        delete_time_entry
      end
    end

    private

    def load_time_entry
      @time_entry = TimeEntry.find_by(entry: entry)
    end

    def started_at
      if rounding
        entry.rounded_started_at
      else
        entry.rounded_started_at round_minutes: 1, nearest: true
      end
    end

    def duration
      if rounding
        entry.rounded_duration
      else
        entry.rounded_duration round_minutes: 1, nearest: true
      end
    end

    def find_domain_by_alias(value)
      Domain.where(user: user).find_by(alias: value)
    end

    def create_or_update_time(domain_alias, task_id, description)
      domain = find_domain_by_alias(domain_alias)

      hours, minutes = get_hours_and_minutes_from_duration(duration)

      attributes = {
        description: description,
        taskId: task_id.to_i,
        date: started_at.strftime('%Y-%m-%d'),
        time: started_at.strftime('%H:%M:%S'),
        hours: hours,
        minutes: minutes
      }

      agent = Teamwork::Api::Agent.new(domain: domain.name, token: domain.token)

      if time_entry
        response = agent.patch_task_time(time_entry.time_entry_id, attributes: attributes)
        response.success?
      else
        response = agent.post_task_time(task_id, attributes: attributes)
        if response.success?
          @time_entry = TimeEntry.create!(
            entry: entry,
            domain: domain,
            time_entry_id: response.body['timelog']['id']
          )
          true
        else
          false
        end
      end
    end

    def delete_time_entry
      domain = time_entry.domain
      agent = Teamwork::Api::Agent.new(domain: domain.name, token: domain.token)
      response = agent.delete_task_time(time_entry.time_entry_id)
      if response.success?
        time_entry.destroy
        @time_entry = nil
        true
      else
        false
      end
    end

    def get_hours_and_minutes_from_duration(duration)
      hours = (duration / 3600) % 3600
      minutes = (duration / 60) % 60
      [ hours, minutes ]
    end

  end
end
