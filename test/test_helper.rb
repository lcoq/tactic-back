ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'
require "minitest/rails"

module TestsExtension
  extend ActiveSupport::Concern

  included do
    include Rails.application.routes.url_helpers

    before do
      DatabaseCleaner.start
    end
    after do
      DatabaseCleaner.clean
    end
  end
end

class ActiveSupport::TestCase
  include TestsExtension
end

class ::Minitest::Spec
  include TestsExtension
end
