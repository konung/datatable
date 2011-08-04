RailsApp::Application.routes.draw do

  match "example1" => "orders#example1", :as => 'example1'
  match "example2" => "orders#example2", :as => 'example2'

  resources :orders

  root :to => "orders#index"
end
