module EntryUpdater

  def self.classes
    Globals.entry_updater_classes
  end

  def self.for(*args)
    klass = classes.detect { |k| k.use_for?(*args) }
    klass.new(*args) if klass
  end
end
