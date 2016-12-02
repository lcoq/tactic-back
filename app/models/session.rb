class Session < ApplicationRecord
  belongs_to :user

  validates :token, presence: true, uniqueness: true

  class << self
    def new_with_generated_token(attributes = {})
      session = new(attributes)
      session.token = SecureRandom.uuid
      session
    end
  end

  def name
    user.name if user
  end
end
