Rails.application.routes.draw do
  scope '/apns' do
    resources :apns_subscriptions,
      path: 'subscriptions',
      param: :platform_device_identifier,
      defaults: { format: :json },
      only: [:create, :destroy]
  end
end
