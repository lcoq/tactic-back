module Teamwork
  class UserConfigSet < ApplicationRecord

    belongs_to :user

    validates :set, presence: true

    def has?(key)
      set.key? key
    end

    def should_keep_without?(key)
      (set.keys - [key]).length > 0
    end

    def get_value(key)
      set[key]
    end

    def set
      super || {}
    end

    def update_value(key, new_value)
      update_attribute :set, set.merge(key => new_value).compact
    end

  end
end
