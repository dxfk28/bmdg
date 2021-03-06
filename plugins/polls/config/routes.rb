# Plugin's routes
# See: http://guides.rubyonrails.org/routing.html
RedmineApp::Application.routes.draw do
  post 'projects/search_index', :controller => 'polls', :action => 'search_index'
  resources :polls do
  	collection do
       post 'point_check_create'
       get 'vote'
       get 'welcome'
       get 'point_check_index'
       get 'point_check_new'
       get 'point_check_list'
       get 'piaoju_index'
       get 'piaoju_moban_index'
       match 'bulk_edit', :via => [:get, :post]
       post 'bulk_update'
       get 'pandian_tubiao'
    end
    member do
       get 'lvli_list' 
    end
  end
  resources :projects do
    resources :polls do
      collection do
         post 'point_check_create'
         post 'queries_create'
         get 'queries_new'
         get 'queries_edit'
         post 'queries_update'
      end
    end
  end

  resources :jia_ju_piaos do
    collection do
      get 'moban_new'
    end
  end
end