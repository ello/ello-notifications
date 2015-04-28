class ApplicationController < ActionController::API
  include ActionController::MimeResponds
  include ActionController::ImplicitRender

  # force JSON
  def require_json
    render nothing: true, status: 406 unless params[:format] == 'json' || request.headers["Accept"] =~ /json/
  end

  # custom error message from strong paramaters
  rescue_from(ActionController::ParameterMissing) do |parameter_missing_exception|
    error = "Missing required paramater: #{parameter_missing_exception.param}"
    response = { error: error }
    render json: response, status: :unprocessable_entity
  end

  protected

  def render_interactor_result(result)
    if result.success?
      render json: { }
    else
      render json: { error: result.message }, status: 403
    end
  end

end
