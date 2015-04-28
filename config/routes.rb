Rails.application.routes.draw do
  scope '/apns' do
    resources :apns_subscriptions,
      path: 'subscriptions',
      param: :platform_device_identifier,
      defaults: { format: :json },
      only: [:create, :destroy]
  end

  post '/users/:destination_user_id/notifications/:notification_type' => 'notifications#create', as: :user_notifications
end
