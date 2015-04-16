Rails.application.routes.draw do
  scope '/apns' do
    resources :apns_subscriptions,
      path: 'subscriptions',
      param: :device_token,
      defaults: { format: :json },
      only: [:create, :destroy]
  end
end
