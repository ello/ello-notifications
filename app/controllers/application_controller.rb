class ApplicationController < ActionController::API
  include ActionController::MimeResponds
  include ActionController::ImplicitRender

  before_filter :check_format

  # force JSON
  def check_format
    render nothing: true, status: 406 unless params[:format] == 'json' || request.headers["Accept"] =~ /json/
  end

  # custom error message from strong paramaters
  rescue_from(ActionController::ParameterMissing) do |parameter_missing_exception|
    error = "Missing required paramater: #{parameter_missing_exception.param}"
    response = { error: error }
    render json: response, status: :unprocessable_entity
  end
end
