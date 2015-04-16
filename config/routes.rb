Rails.application.routes.draw do
  scope '/apns' do
    resources :apns_subscriptions,
      path: 'subscriptions',
      defaults: { format: :json },
      only: [:create]
  end
end
