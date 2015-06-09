class StatusController < ApplicationController

  skip_before_filter :require_binary_request

  def health_check
    render text: 'Service Up'
  end

  private

  def require_auth?
    false
  end

end
