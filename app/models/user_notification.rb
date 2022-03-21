class UserNotification < ApplicationRecord
  include ValidatableEnum

  belongs_to :user
  belongs_to :resource, polymorphic: true, optional: true

  enum nature: { info: 'info', warning: 'warning', error: 'error' }, _prefix: true
  enum status: { unread: 'unread', read: 'read' }, _prefix: true

  validatable_enum :nature
  validatable_enum :status

  validates :nature, presence: true, inclusion: natures.values
  validates :status, presence: true, inclusion: statuses.values
  validates :message, presence: { message: "cannot be blank without title" }, if: ->(n) { n.title.blank? }
end
