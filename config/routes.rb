Mon::Application.routes.draw do
    resources :sessions, only: [:new, :create, :destroy]
    resources :computers
    resources :users
    match 'api/add_entry',                to: 'api#add_entry',               via: 'post'
    match '/signin',                      to: 'sessions#new',                via: 'get'
    match '/signout',                     to: 'sessions#destroy',            via: 'delete'

    match '/load_data/stats/:id',         to: 'computers#get_stats',         via: 'get'
    match '/load_data/stats/:id/current', to: 'computers#get_stats_current', via: 'get'
    match '/load_data/partitions/:id',    to: 'computers#get_partitions',    via: 'get'
    match '/load_data/partitions/:id/current',    to: 'computers#get_partitions_current',    via: 'get'
    match '/load_data/disk_reads/:id',    to: 'computers#get_disk_reads',    via: 'get'
    match '/load_data/disk_reads/:id/current',    to: 'computers#get_disk_reads_current',    via: 'get'
    match '/load_data/disk_writes/:id',   to: 'computers#get_disk_writes',   via: 'get'
    match '/load_data/disk_writes/:id/current',   to: 'computers#get_disk_writes_current',   via: 'get'
    match '/load_data/interfaces_rx/:id', to: 'computers#get_interfaces_rx', via: 'get'
    match '/load_data/interfaces_rx/:id/current', to: 'computers#get_interfaces_rx_current', via: 'get'
    match '/load_data/interfaces_tx/:id', to: 'computers#get_interfaces_tx', via: 'get'
    match '/load_data/interfaces_tx/:id/current', to: 'computers#get_interfaces_tx_current', via: 'get'
    match '/load_data/programs/:id',      to: 'computers#get_programs',      via: 'get'

    root 'computers#index'
  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  # root 'welcome#index'

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end
