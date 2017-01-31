class Session < ApplicationRecord
  belongs_to :user

  validates :token, presence: true, uniqueness: true
  validates :password, presence: true
  validate :user_authenticate_with_password, if: :user

  class << self
    def new_with_generated_token(attributes = {})
      session = new(attributes)
      session.token = SecureRandom.uuid
      session
    end
  end

  attr_accessor :password

  def name
    user.name if user
  end

  private

  def user_authenticate_with_password
    if user && password && !user.authenticate(password)
      errors.add(:user, :blank, message: I18n.t('errors.messages.required'))
    end
  end
end
