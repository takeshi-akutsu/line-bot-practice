Rails.application.routes.draw do
  root "top#index"
  post '/callback' => 'webhook#callback'
end
