class ApplicationController < ActionController::API
  serialization_scope :serialization_context # https://github.com/rails-api/active_model_serializers/blob/master/docs/general/serializers.md#controller-authorization-context

  def authenticate
    token = request.headers['Authorization']
    @current_session = token.presence && Session.find_by(token: token)
    unless @current_session
      render json: {}, status: :forbidden
      return false
    end
  end

  def current_user
    @current_session.user
  end
end
