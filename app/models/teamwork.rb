module Teamwork
  def self.table_name_prefix
    'teamwork_'
  end

  def self.initialize
    ActiveSupport.on_load(:active_record) do
      ::User.include Teamwork::HasManyDomains
    end
  end
end
