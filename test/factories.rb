module Factories
  def self.factory(type, &block)
    define_method "#{type}_default_attributes" do
      block ? block.() : {}
    end
    define_method "build_#{type}" do |attributes|
      build_record type, attributes
    end
    define_method "create_#{type}" do |attributes|
      create_record type, attributes
    end
    define_method "save_#{type}" do |record|
      save_record record
    end
  end

  factory :user

  factory :session do
    { token: SecureRandom.uuid }
  end

  factory :entry do
    { started_at: Time.zone.now - 2.hours, stopped_at: Time.zone.now - 1.hour }
  end

  factory :project do
    { name: "Tictac" }
  end

  private

  def build_record(type, attributes)
    klass = type.to_s.classify.constantize
    default_attributes = public_send("#{type}_default_attributes")
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
end
