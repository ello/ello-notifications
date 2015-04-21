require 'rails_helper'

describe NotificationsController, type: :request do

  describe 'POST #create' do
    context 'with content-type HTML' do
      it 'fails with status code 406' do
        post activity_notifications_path

        expect(response.code).to eq '406'
      end
    end

    context 'using content-type JSON' do
      let(:headers) { { 'CONTENT_TYPE' => 'application/json', 'ACCEPT' => 'application/json' } }

      context 'when missing the activity' do
        before { post(activity_notifications_path, { destination_user_id: '1234' }.to_json, headers) }

        it 'fails with status code 422' do
          expect(response.code).to eq '422'
        end

        it 'notifies the client of the missing paramater in the response' do
          error = parse_json(response.body, 'error')
          expect(error).to eq 'Missing required paramater: activity'
        end
      end

      context 'when missing the destination_user_id' do
        before { post(activity_notifications_path, { activity: { id: '5678' } }.to_json, headers) }

        it 'fails with status code 422' do
          expect(response.code).to eq '422'
        end

        it 'notifies the client of the missing paramater in the response' do
          error = parse_json(response.body, 'error')
          expect(error).to eq 'Missing required paramater: destination_user_id'
        end
      end

      context 'with all required params' do
        let(:required_params) do
          {
            destination_user_id: '1234',
            activity: {
              id: '5678'
            }
          }
        end

        context 'when the creation succeeds' do
          before do
            successful_context = double('Context', success?: true)
            allow(DeliverNotificationsForActivity).to receive(:call).and_return(successful_context)

            post activity_notifications_path, required_params.to_json, headers
          end

          it 'passes the device token and bundle id to the interactor' do
            expect(DeliverNotificationsForActivity).to have_received(:call).with({
              destination_user_id: '1234',
              activity: {
                id: '5678'
              }
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
            allow(DeliverNotificationsForActivity).to receive(:call).and_return(failed_context)

            post activity_notifications_path, required_params.to_json, headers
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
