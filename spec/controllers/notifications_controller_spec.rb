require 'rails_helper'

describe NotificationsController, type: :request do

  describe 'POST #create' do
    context 'with content-type HTML' do
      it 'fails with status code 406' do
        post user_notifications_path(destination_user_id: '1234', notification_type: 'some_type')

        expect(response.code).to eq '406'
      end
    end

    context 'using content-type JSON' do
      let(:headers) { { 'CONTENT_TYPE' => 'application/octet-stream', 'ACCEPT' => 'application/json' } }

      context 'with all required params' do
        let(:required_params) do
          {
            destination_user_id: '1234',
            notification_type: 'follower'
          }
        end

        context 'when the creation succeeds' do
          let(:request_body) { create(:protobuf_user).encode }
          before do
            successful_context = double('Context', success?: true)
            allow(NotifyUser).to receive(:call).and_return(successful_context)

            post user_notifications_path(required_params), request_body, headers
          end

          it 'passes the required params and request body to the interactor' do
            expect(NotifyUser).to have_received(:call).with({
              destination_user_id: '1234',
              notification_type: 'follower',
              request_body: request.body
            })
          end

          it 'succeeds with status code 200' do
            expect(response.code).to eq '200'
          end
        end

        context 'when the creation fails' do
          let(:expected_error) { 'An error occurred' }

          before do
            failed_context = double('Context', success?: false, message: expected_error)
            allow(NotifyUser).to receive(:call).and_return(failed_context)

            post user_notifications_path(required_params), nil, headers
          end

          it 'fails with status code 403' do
            expect(response.code).to eq '403'
          end

          it 'renders the creation error message in the response' do
            error = parse_json(response.body, 'error')
            expect(error).to eq expected_error
          end
        end
      end
    end
  end

end
