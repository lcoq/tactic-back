ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'
require "minitest/rails"

require 'factories'

module TestsExtension
  extend ActiveSupport::Concern
  include Factories

  included do
    include Rails.application.routes.url_helpers

    before do
      DatabaseCleaner.start
    end
    after do
      DatabaseCleaner.clean
    end
  end

  def serialized(resource, serializer_class, adapter_options = {})
    serializer =
      if resource.respond_to?(:each)
        ActiveModel::Serializer::CollectionSerializer.new(resource, serializer: serializer_class)
      else
        serializer_class.new(resource)
      end
    ActiveModelSerializers::Adapter.create(serializer, adapter_options).to_json
  end
end

class ActiveSupport::TestCase
  include TestsExtension
end

class ::Minitest::Spec
  include TestsExtension
end
