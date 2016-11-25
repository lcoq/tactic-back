class User < ApplicationRecord
  default_scope { order(created_at: :desc) }

  validates :name, presence: true, uniqueness: { case_sensitive: false }
end
