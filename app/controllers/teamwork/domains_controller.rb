module Teamwork
  class DomainsController < ApplicationController
    before_action :authenticate

    def index
      @domains = Domain.where(user: current_user).order(:name)
      render json: @domains
    end

    def create
      @domain = Domain.new(user: current_user)
      if @domain.update(create_params)
        render json: @domain
      else
        render_record_error @domain
      end
    end

    def update
      @domain = Domain.find(params[:id])
      if @domain.update(update_params)
        render json: @domain
      else
        render_record_error @domain
      end
    end

    def destroy
      @domain = Domain.find(params[:id])
      @domain.destroy
      head :no_content
    end

    private

    def create_params
      authorized = %w{ name alias token }
      ActiveModelSerializers::Deserialization.jsonapi_parse!(params, only: authorized)
    end

    def update_params
      authorized = %w{ name alias token }
      ActiveModelSerializers::Deserialization.jsonapi_parse!(params, only: authorized)
    end

  end
end
