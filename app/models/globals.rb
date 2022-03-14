class Globals

  include HiddenSingleton

  attr_reader :user_config_definitions,
              :entry_updater_classes

  def initialize
    @user_config_definitions = Set.new
    @entry_updater_classes = []
  end

  def register_user_config_definition(definition)
    user_config_definitions << definition
  end

  def register_entry_updater_class(klass)
    unless @entry_updater_classes.include?(klass)
      @entry_updater_classes.unshift klass
    end
  end

  def entry_updater_classes
    @entry_updater_classes.freeze
    @entry_updater_classes
  end

  register_user_config_definition(
    name: 'summary rounding',
    type: :boolean,
    description: "Enable to round entries durations by default on weekly and monthly summaries"
  )
  register_user_config_definition(
    name: 'reviews rounding',
    type: :boolean,
    description: "Enable to round entries durations by default on reviews page"
  )

  register_entry_updater_class EntryUpdater::DefaultUpdater
end
