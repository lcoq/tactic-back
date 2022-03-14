module EntryUpdater
  class DefaultUpdater

    def self.use_for?(entry, context)
      true
    end

    attr_reader :entry

    def initialize(entry, context)
      @entry = entry
    end

    def update(attributes)
      entry.update_attributes attributes
    end

    def destroy
      entry.destroy
    end

  end
end
