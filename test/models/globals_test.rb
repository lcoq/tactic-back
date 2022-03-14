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
    it 'has EntryUpdater::DefaultUpdater as last updater' do
      assert_equal EntryUpdater::DefaultUpdater, subject.entry_updater_classes.last
    end
  end

  it 'register user config definition' do
    definition = { name: 'test', type: :boolean }
    subject.register_user_config_definition definition
    assert_includes subject.user_config_definitions, definition
  end

  it 'registers an entry updater class' do
    subject.register_entry_updater_class :foo
    assert_includes subject.entry_updater_classes, :foo
  end
  it 'does not register an entry updater class twice' do
    subject.register_entry_updater_class :foo
    subject.register_entry_updater_class :foo
    assert_equal 1, subject.entry_updater_classes.length
  end
  it 'unshifts entry updater classes' do
    subject.register_entry_updater_class :foo
    subject.register_entry_updater_class :bar
    assert subject.entry_updater_classes.index(:bar) < subject.entry_updater_classes.index(:foo)
  end
  it 'freezes entry updater classes on get' do
    subject.entry_updater_classes
    assert_raises { subject.register_entry_updater_class(:foo) }
  end
end
