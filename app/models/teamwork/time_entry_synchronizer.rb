module Teamwork
  class TimeEntrySynchronizer

    class SynchroError < StandardError; end

    TASK_REGEXP = /\A\[([^\/]+)\/(\d+)\]\s*(.*)\Z/

    class << self
      def synchronize!(*args)
        new(*args).synchronize!
      end

      def synchronize(*args)
        new(*args).synchronize
      end

      def destroy!(*args)
        new(*args).destroy
      end

      def destroy(*args)
        new(*args).destroy
      end

      def destroy_time_entry!(time_entry_id)
        new(nil, user: nil).destroy! time_entry_id
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

    def synchronize!
      @time_entry = TimeEntry.find_by(entry: entry)
      @rounding = Teamwork::UserConfig.find_for_user(user, 'teamwork-task-time-entry-rounding').value
      perform_synchronize
      true
    end

    def synchronize
      synchronize!
    rescue SynchroError
      Delayed::Job.enqueue Teamwork::TimeEntrySynchronizeJob.new(entry.id, user.id)
      false
    end

    def destroy!(custom_time_entry = nil)
      @time_entry = custom_time_entry || TimeEntry.find_by(entry: entry)
      return true if !time_entry
      perform_destroy
      true
    end

    def destroy(*args)
      destroy! *args
    rescue SynchroError => error
      hours, minutes = entry && duration && get_hours_and_minutes_from_duration(duration)
      job = Teamwork::TimeEntryDestroyJob.new(
        time_entry.id,
        entry_title: entry && entry.title,
        entry_duration: hours && minutes && "#{hours}h#{"%02.f" % minutes}min",
        entry_started_at: entry && entry.started_at,
      )
      Delayed::Job.enqueue job
      false
    end

    private

    def perform_synchronize
      if entry.title && entry.title.match(TASK_REGEXP) && entry.stopped? && duration > 0
        domain_alias, task_id, description = [ $1, $2, $3 ]
        create_or_update_time domain_alias, task_id, description
      elsif time_entry
        delete_time_entry
      end
    rescue SynchroError
      raise
    rescue => error
      log_error error
      raise SynchroError, "Cannot synchronize time entry: #{error.inspect}"
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
        if response.failure?
          raise SynchroError, "Error on PATCH time entry (code: #{response.code}) : #{response.body.inspect}"
        end
      else
        response = agent.post_task_time(task_id, attributes: attributes)
        if response.success?
          @time_entry = TimeEntry.create!(
            entry: entry,
            domain: domain,
            time_entry_id: response.body['timelog']['id']
          )
        else
          raise SynchroError, "Error on POST time entry (code: #{response.code}) : #{response.body.inspect}"
        end
      end
    end

    def perform_destroy
      delete_time_entry
    rescue SynchroError
      raise
    rescue => error
      log_error error
      raise SynchroError, "Cannot destroy time entry: #{error.inspect}"
    end

    def delete_time_entry
      domain = time_entry.domain
      agent = Teamwork::Api::Agent.new(domain: domain.name, token: domain.token)
      response = agent.delete_task_time(time_entry.time_entry_id)
      if response.success?
        time_entry.destroy
        @time_entry = nil
      else
        raise SynchroError, "Error on DELETE time entry (code: #{response.code}) : #{response.body.inspect}"
      end
    end

    def get_hours_and_minutes_from_duration(duration)
      hours = (duration / 3600) % 3600
      minutes = (duration / 60) % 60
      [ hours, minutes ]
    end

    def log_error(error)
      Rails.logger.info "[#{self.class.name}] Error during #create_or_update_time : #{error.inspect}"
      Rails.logger.info "[#{self.class.name}] #{error.backtrace[0...20]}"
    end

  end
end
