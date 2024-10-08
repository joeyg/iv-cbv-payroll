require "sidekiq/web"

Rails.application.routes.draw do
  if Rails.env.development?
    mount Sidekiq::Web => "/sidekiq"
  end
  scope "(:locale)", locale: /#{I18n.available_locales.join("|")}/ do
    # Your application routes go here
    root "pages#home"

    get "/health", to: "health_check#ok"
    get "/health/test_rendering", to: "health_check#test_rendering"
    # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

    scope "/cbv", as: :cbv_flow, module: :cbv do
      resource :entry, only: %i[show]
      resource :employer_search, only: %i[show]
      resource :summary, only: %i[show update]
      resource :share, only: %i[show update]
      resource :missing_results, only: %i[show]
      resource :success, only: %i[show]
      resource :agreement, only: %i[show create]
      resource :add_job, only: %i[show create]
      resource :payment_details, only: %i[show update]

      # Utility route to clear your session; useful during development
      resource :reset, only: %i[show]
    end

    # Temporarily redirect /invivations/new -> /nyc/invitations/new
    # (remove this once people know about the new invitation URL)
    get "/invitations/new", to: redirect { |_, req| "/nyc/invitations/new?secret=#{req.params[:secret]}" }

    scope "/:site_id" do
      resources :cbv_flow_invitations, as: :invitations, path: :invitations, only: %i[new create]
    end
  end

  namespace :webhooks do
    namespace :pinwheel do
      resources :events, only: :create
    end
  end

  namespace :api do
    scope :pinwheel do
      post "/tokens" => "pinwheel#create_token"
    end
  end
end
