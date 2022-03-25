module Teamwork
  class EntryTitleBuilder

    TASK_URL_REGEXP = /\Ahttps:\/\/([^.]+)\.teamwork\.com\/#\/tasks\/(\d+)\s*\Z/i
    TASK_FORMAT = "[%{domain_alias}/%{task_id}] %{task_title}"

    def self.build(*args, **kwargs)
      new(*args, **kwargs).build
    end

    attr_reader :title,
                :domains,
                :replace_task_url

    def initialize(title, domains:, replace_task_url:)
      @title = title
      @domains = domains
      @replace_task_url = replace_task_url
    end

    def build
      (replace_task_url && compute_title_from_task) || title
    end

    private

    def compute_title_from_task
      return unless title.match(TASK_URL_REGEXP)
      domain_name, task_id = [ $1, $2 ]
      domain = domains.detect { |d| d.name == domain_name }
      return unless domain
      task_title = fetch_task_title(domain, task_id) || ''
      TASK_FORMAT
        .sub('%{domain_alias}', domain.alias)
        .sub('%{task_id}', task_id)
        .sub('%{task_title}', task_title)
    end

    def fetch_task_title(domain, task_id)
      agent = Teamwork::Api::Agent.new(domain: domain.name, token: domain.token)
      response = agent.get_task(task_id, query: { 'fields[task]' => 'name' })
      response.body['task']['name'] if response.success? && response.body['task'].present?
    end

  end
end
