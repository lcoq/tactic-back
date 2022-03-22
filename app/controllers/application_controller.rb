class ApplicationController < ActionController::API
  serialization_scope :serialization_context # https://github.com/rails-api/active_model_serializers/blob/master/docs/general/serializers.md#controller-authorization-context

  def authenticate
    token = request.headers['Authorization']
    return authenticate_with_token(token)
  end

  def authenticate_from_headers_or_params
    token = request.headers['Authorization'] || params['Authorization']
    return authenticate_with_token(token)
  end

  def current_user
    @current_session.user
  end

  private

  def render_record_error(object)
    render json: object, status: :unprocessable_entity, serializer: ActiveModel::Serializer::ErrorSerializer
  end

  def authenticate_with_token(token)
    @current_session = token.presence && Session.find_by(token: token)
    unless @current_session
      render_forbidden
      return false
    end
  end

  def render_forbidden
    render json: {}, status: :forbidden
  end
end
