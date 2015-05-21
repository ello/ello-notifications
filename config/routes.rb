Rails.application.routes.draw do
  scope '/apns' do
    resources :apns_subscriptions,
      path: 'subscriptions',
      param: :platform_device_identifier,
      defaults: { format: :json },
      only: [:create, :destroy]
  end

  scope '/device_subscriptions' do
    post 'create' => 'device_subscriptions#create', as: :create_device_subscription
    post 'delete' => 'device_subscriptions#destroy', as: :delete_device_subscription
  end

  post '/notifications/create' => 'notifications#create', as: :create_notification
end
