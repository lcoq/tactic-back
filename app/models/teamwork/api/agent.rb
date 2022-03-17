module Teamwork
  module Api
    class Agent

      attr_reader :domain,
                  :token

      def initialize(domain:, token:)
        @domain = domain
        @token = token
      end

      def get_task(task_id, query: {})
        path = "projects/api/v3/tasks/#{task_id}"
        get_request path, query: query
      end

      def get_task_times(task_id, query: {})
        path = "projects/api/v3/tasks/#{task_id}/time"
        get_request path, query: query
      end

      def patch_task_time(task_time_id, attributes:)
        path = "projects/api/v3/time/#{task_time_id}"
        patch_request path, body: { 'timelog' => attributes }.to_json
      end

      def post_task_time(task_id, attributes:)
        path = "projects/api/v3/tasks/#{task_id}/time"
        post_request path, body: { 'timelog' => attributes }.to_json
      end

      def delete_task_time(task_time_id)
        path = "projects/api/v3/time/#{task_time_id}"
        delete_request path
      end

      private

      def get_request(path, query: {})
        url = build_url(path)
        options = request_options(query: query)
        response = HTTParty.get(url, options)
        Response.new response
      end

      def post_request(path, body:)
        url = build_url(path)
        options = request_options(body: body)
        response = HTTParty.post(url, options)
        Response.new response
      end

      def patch_request(path, body:)
        url = build_url(path)
        options = request_options(body: body)
        response = HTTParty.patch(url, options)
        Response.new response
      end

      def delete_request(path)
        url = build_url(path)
        response = HTTParty.delete(url, request_options)
        Response.new response
      end

      def build_url(path)
        "https://#{domain}.teamwork.com/#{path}"
      end

      def request_options(options = {})
        default_request_options.merge options
      end

      def default_request_options
        {
          basic_auth: {
            username: token,
            password: "X"
          },
          headers: {
            'Content-Type' => 'application/json',
            'Accept'=> 'application/json'
          },
          logger: Rails.logger,
          timeout: 10
        }
      end

    end
  end
end
