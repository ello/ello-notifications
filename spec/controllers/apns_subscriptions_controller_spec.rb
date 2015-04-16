require 'rails_helper'

describe ApnsSubscriptionsController, type: :request do

  describe 'POST #create' do
    context 'with content-type HTML' do
      it 'fails with status code 406' do
        post apns_subscriptions_path

        expect(response.code).to eq '406'
      end
    end

    context 'using content-type JSON' do
      let(:headers) { { 'CONTENT_TYPE' => 'application/json', 'ACCEPT' => 'application/json' } }

      context 'with missing params' do
        let(:invalid_params) { { bad: 'params' } }

        before { post(apns_subscriptions_path, invalid_params.to_json, headers) }

        it 'fails with status code 422' do
          expect(response.code).to eq '422'
        end

        it 'notifies the client of the missing paramater in the response' do
          error = parse_json(response.body, 'error')
          expect(error).to eq 'Missing required paramater: bundle_id'
        end
      end

      context 'with all required params' do
        let(:required_params) do
          { bundle_id: '1234',
            device_token: '5678'
          }
        end

        context 'when the creation succeeds' do
          before do
            successful_context = double('Context', success?: true)
            allow(APNS::CreateSubscription).to receive(:call).and_return(successful_context)

            post apns_subscriptions_path, required_params.to_json, headers
          end

          it 'succeeds with status code 200' do
            expect(response.code).to eq '200'
          end
        end

        context 'when the creation fails' do
          let(:expected_error) { 'An error occurred' }

          before do
            failed_context = double('Context', success?: false, message: expected_error)
            allow(APNS::CreateSubscription).to receive(:call).and_return(failed_context)

            post apns_subscriptions_path, required_params.to_json, headers
          end

          it 'fails with status code 403' do
            expect(response.code).to eq '403'
          end

          it 'renders the subscription error message in the response' do
            error = parse_json(response.body, 'error')
            expect(error).to eq expected_error
          end
        end
      end
    end
  end

end
