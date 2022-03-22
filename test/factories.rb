module Factories
  def self.factory(type, &block)
    formatted_type_for_method = type.to_s.gsub(/\//, '_')
    define_method "#{formatted_type_for_method}_default_attributes" do
      block ? block.() : {}
    end
    define_method "build_#{formatted_type_for_method}" do |attributes|
      build_record type, attributes
    end
    define_method "create_#{formatted_type_for_method}" do |attributes|
      create_record type, attributes
    end
    define_method "save_#{formatted_type_for_method}" do |record|
      save_record record
    end
  end

  factory :user do
    { password: 'my-password' }
  end

  factory :session do
    { token: SecureRandom.uuid, password: 'my-password' }
  end

  factory :entry do
    { started_at: Time.zone.now - 2.hours, stopped_at: Time.zone.now - 1.hour }
  end

  factory :project do
    { name: "Tictac" }
  end

  factory :client do
    { name: "Client" }
  end

  factory :entries_stat do
    { date: Date.yesterday, duration: 300 }
  end

  factory :entries_stat_group do
    { title: "My entries stat group", nature: "hour/month", entries_stats: [] }
  end

  factory 'teamwork/domain' do
    { name: "Tactic", alias: "tc", token: "my-token" }
  end

  factory 'teamwork/user_config_set' do
    { set: { 'test' => true } }
  end

  factory 'teamwork/time_entry' do
    { time_entry_id: 12345 }
  end

  factory :user_notification do
    { title: "My user notification title", message: "My user notification message" }
  end

  private

  def build_record(type, attributes)
    klass = type.to_s.classify.constantize
    default_attributes = public_send("#{type_for_method(type)}_default_attributes")
    klass.new default_attributes.merge(attributes)
  end

  def create_record(type, attributes)
    record = build_record(type, attributes)
    save_record record
    record
  end

  def save_record(record)
    assert record.save
  end

  def type_for_method(type)
    type.to_s.gsub(/\//, '_')
  end
end
