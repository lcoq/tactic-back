module Teamwork
  module Api
    class Response

      def initialize(response)
        @response = response
      end

      def success?
        (200...300).include? code
      end

      def failure?
        !success?
      end

      def code
        response.code
      end

      def body
        return unless response.body.present?
        JSON.parse response.body
      end

      private

      attr_reader :response

    end
  end
end
