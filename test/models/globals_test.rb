require 'test_helper.rb'

describe Globals do
  let(:klass) { Class.new(Globals) }
  subject { klass }

  describe 'Real class' do
    subject { Globals }

    it 'has summary rounding config' do
      definition = {
        name: 'summary rounding',
        type: :boolean,
        description: "Enable to round entries durations by default on weekly and monthly summaries"
      }
      assert_includes subject.user_config_definitions, definition
    end
    it 'has reviews rounding config' do
      definition = {
        name: 'reviews rounding',
        type: :boolean,
        description: "Enable to round entries durations by default on reviews page"
      }
      assert_includes subject.user_config_definitions, definition
    end
  end

  it 'register user config definition' do
    definition = { name: 'test', type: :boolean }
    subject.register_user_config_definition definition
      assert_includes subject.user_config_definitions, definition
  end
end
