# Plugin's routes
# See: http://guides.rubyonrails.org/routing.html
RedmineApp::Application.routes.draw do
  get 'projects/:id/search_index', :controller => 'polls', :action => 'search_index'
  resources :polls do
  	collection do
       post 'point_check_create'
       get 'vote'
       get 'welcome'
       get 'point_check_index'
       get 'point_check_new'
       get 'point_check_list'
    end
  end
  resources :projects do
    resources :polls do
      collection do
         post 'point_check_create'
      end
    end
  end
end