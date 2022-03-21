class User < ApplicationRecord

  has_many :notifications, class_name: 'UserNotification', dependent: :destroy
  has_many :sessions, dependent: :destroy
  has_many :entries, dependent: :destroy do
    def running
      where(stopped_at: nil).take
    end
  end

  validates :name, presence: true, uniqueness: { case_sensitive: false }
  validates :password, presence: true, unless: :persisted?
  validates :password, length: { minimum: 8 }, allow_blank: true

  default_scope { order(:name) }

  before_save :encrypt_password, if: :password

  attr_reader :password

  def authenticate(raw_password)
    encrypt_string("#{salt}--#{raw_password}") == encrypted_password
  end

  def password=(new_password)
    return unless new_password.present?
    self.salt = nil
    self.encrypted_password = nil
    @password = new_password
  end

  def recent_entries
    entries.recent
  end

  def running_entry
    entries.running
  end

  def configs
    super || {}
  end

  private

  def encrypt_password
    self.salt = encrypt_string(random_string)
    self.encrypted_password = encrypt_string("#{salt}--#{password}")
    @password = nil
  end

  def encrypt_string(string)
    Digest::SHA1.hexdigest string
  end

  def random_string
    "#{Time.now}+#{rand(10000)}"
  end
end
