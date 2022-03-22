module Teamwork
  class UserConfig
    extend ActiveModel::Naming
    include ActiveModel::Serialization

    DEFINITIONS = [
      {
        name: 'teamwork task url replace',
        description: "Enable to automatically replace teamwork task URLs in entry title with the Teamwork task id and name",
        default: true
      },
      {
        name: 'teamwork task time entry synchronization',
        description: "Enable to automatically synchronize stopped entries with Teamwork task time entries",
        default: false
      },
      {
        name: 'teamwork task time entry rounding',
        description: "Enable to send rounded entries durations to Teamwork (require Teamwork task time entry synchronization)",
        default: false
      }
    ]

    def self.list_for_user(user)
      DEFINITIONS.map do |definition|
        new user, definition
      end
    end

    def self.find_for_user(user, id)
      list_for_user(user).detect { |d| d.id == id }
    end

    attr_reader :user,
                :definition

    def initialize(user, definition)
      @user = user
      @definition = definition
    end

    def id
      name.parameterize
    end

    def name
      definition[:name]
    end

    def description
      definition[:description]
    end

    def value
      read_value id
    end

    def update_value(new_value)
      return false unless [true, false].include?(new_value)
      write_value id, new_value
    end

    def attributes
      {
        name: name,
        value: value,
        description: description
      }
    end

    private

    def read_value(key)
      set = UserConfigSet.find_by(user: user)
      set && set.has?(key) ? set.get_value(key) : definition[:default]
    end

    def write_value(id, new_value)
      set = UserConfigSet.find_or_initialize_by(user: user)
      if new_value != definition[:default]
        set.update_value id, new_value
      elsif set.should_keep_without?(id)
        set.update_value id, nil
      else
        set.destroy
      end
      true
    end

  end
end
