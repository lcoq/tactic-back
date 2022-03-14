module Teamwork
  class UserConfigsController < ApplicationController
    before_action :authenticate

    def index
      @configs = Teamwork::UserConfig.list_for_user(current_user)
      render json: @configs
    end

    def update
      @config = Teamwork::UserConfig.find_for_user(current_user, params[:id])
      if @config.update_value(update_params[:value])
        render json: @config
      else
        render_value_error
      end
    end

    private

    def update_params
      authorized = %w{ value }
      ActiveModelSerializers::Deserialization.jsonapi_parse!(params, only: authorized)
    end

    def render_value_error
      json = {
        'errors' => [
          {
            'source' => {
              'pointer' => '/data/attributes/value'
            },
            'detail' => "is not a boolean"
          }
        ]
      }
      render json: json, status: :unprocessable_entity
    end

  end
end
