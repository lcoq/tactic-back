module EntryUpdater

  def self.classes
    Globals.entry_updater_classes
  end

  def self.for(*args, **kwargs)
    klass = classes.detect { |k| k.use_for?(*args, **kwargs) }
    klass.new(*args, **kwargs) if klass
  end
end
