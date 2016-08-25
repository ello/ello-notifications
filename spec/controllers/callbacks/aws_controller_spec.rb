require 'rails_helper'

describe AWSController, type: :request do

  describe 'POST #push_failed' do
    context 'with a validated message' do
      context 'message is a failed push notification' do
        it 'deletes the device subscription' do
        end
      end

      context 'message is NOT a failed push notification' do
        it 'exits immediately with an empty json' do
        end
      end
    end

    context 'with an unvalidated message' do
      it 'exits immediately with an empty json' do
      end
    end
  end
end
