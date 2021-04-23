# frozen_string_literal: true

require 'rails_helper'

describe StatusController do

  describe 'GET #health_check' do
    it 'returns a successful health check value' do
      get :health_check

      expect(response).to be_success
      expect(response.body).to include('Service Up')
    end
  end

end
