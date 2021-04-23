# frozen_string_literal: true

class StatusController < ApplicationController

  skip_before_action :require_binary_request

  def health_check
    render text: 'Service Up'
  end

  private

  def require_auth?
    false
  end

end
