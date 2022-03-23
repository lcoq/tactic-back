class UserNotificationList
  extend ActiveModel::Naming
  include ActiveModel::Serialization

  class << self
    def latest(user)
      new user, before: Time.zone.now
    end

    def find_for_user(user, before)
      before = Time.zone.parse(before) if before.kind_of?(String)
      new user, before: before
    end
  end

  attr_reader :user,
              :before,
              :notifications

  def initialize(user, before:)
    @user = user
    @before = before
    @notifications = find_notifications
  end

  def id
    before.iso8601
  end

  def attributes
    {}
  end

  def update(attributes)
    errored = false
    UserNotification.transaction do
      notifications.each do |notification|
        unless notification.update(attributes)
          errored = true
          raise ActiveRecord::Rollback
        end
      end
    end
    !errored
  end

  def errors
    notif = notifications.detect { |n| n.errors.present? }
    notif.try(:errors) || ActiveModel::Errors.new(self)
  end

  private

  def find_notifications
    UserNotification.
      where(user: user).
      where('created_at <= ?', before).
      order(created_at: :desc)
  end
end
