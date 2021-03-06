# frozen_string_literal: true

Rails.application.routes.draw do
  scope '/device_subscriptions' do
    post 'create' => 'device_subscriptions#create', as: :create_device_subscription
    post 'delete' => 'device_subscriptions#destroy', as: :delete_device_subscription
  end

  post '/notifications/create' => 'notifications#create', as: :create_notification
  post '/topic_notifications/create' => 'topic_notifications#create', as: :create_topic_notification

  post '/callbacks/aws/push_failed' => 'callbacks/aws#push_failed'

  get '/health_check' => 'status#health_check'
end
