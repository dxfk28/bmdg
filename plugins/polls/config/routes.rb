# Plugin's routes
# See: http://guides.rubyonrails.org/routing.html
RedmineApp::Application.routes.draw do
  resources :polls do
  	collection do
       get 'point_check_create'
       get 'vote'
       get 'welcome'
       get 'point_check_index'
       get 'point_check_new'
       get 'point_check_list'
    end
  end
end