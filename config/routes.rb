Rails.application.routes.draw do
  # Authentication
  devise_for :users

  # Account / profile (all signed-in roles)
  resource :profile, only: [ :show, :update ]

  # Public Website
  root "public/home#index"

  scope module: :public do
    get "about", to: "home#about", as: :about
    get "services", to: "home#services", as: :public_services
    get "contact", to: "contact#new", as: :contact
    post "contact", to: "contact#create"
    resources :doctors, only: [ :index, :show ]
    resources :blog, only: [ :index, :show ], controller: "blog_posts", as: :blog_posts
    resources :testimonials, only: [ :index ]
  end

  # Patient Portal
  namespace :patient_portal do
    root "dashboard#index"
    resources :appointments do
      member do
        patch :cancel
      end
      collection do
        get :doctors_for_department
        get :available_dates
        get :available_slots
      end
    end
    get "assistant", to: "assistant#index"
    post "assistant/message", to: "assistant#message", as: :assistant_message
    resources :medical_records, only: [ :index ]
    resources :lab_results, only: [ :index, :show ]
    resources :prescriptions, only: [ :index, :show ]
    resources :dialysis_history, only: [ :index, :show ]
    resources :diet_logs
    resources :emergency_contacts
    resources :surveys, only: [:new, :create], controller: "surveys"
    resources :invoices, only: [ :index, :show ] do
      member do
        get :pay
        post :initiate_payment
      end
    end
    resources :payments, only: [ :index, :show ] do
      collection do
        get :callback
      end
    end
    resources :conversations do
      resources :messages, only: [ :create ]
    end
  end

  # Staff (Doctors + Nurses)
  namespace :staff do
    root "dashboard#index"
    resources :appointments, only: [ :index, :show, :update ] do
      member do
        patch :start
        patch :complete
      end
    end
    resources :doctor_schedules, only: [ :index, :create, :update, :destroy ]
    resources :patients, only: [ :index, :show ] do
      member do
        get :chart
      end
      resources :visits, only: [ :index, :new, :create, :show, :update ] do
        resources :clinical_notes, only: [ :create ]
      end
      resources :vital_signs, only: [ :new, :create ]
      resources :diagnoses, only: [ :new, :create, :edit, :update ]
      resources :allergies, only: [ :new, :create, :edit, :update, :destroy ]
      resources :medications, only: [ :new, :create, :edit, :update ]
      resources :lab_orders, only: [ :new, :create, :show, :update ]
      resources :prescriptions, only: [ :new, :create, :show ]
    end
    resources :lab_results, only: [ :edit, :update ]
    post "ai/scribe", to: "ai#scribe", as: :ai_scribe
    resources :dialysis_sessions do
      member do
        patch :start
        patch :complete
        patch :assign_resources
      end
      collection do
        get :board
      end
    end
  end

  # Receptionist
  namespace :receptionist do
    root "dashboard#index"
    resources :appointments do
      member do
        patch :check_in
        patch :cancel
      end
      collection do
        get :today
        get :queue
      end
    end
    resources :invoices do
      member do
        patch :send_invoice
      end
    end
    resources :payments, only: [ :new, :create ]
    resources :insurance_claims
  end

  # Admin
  namespace :admin do
    root "dashboard#index"
    resources :users
    resources :departments
    resources :services
    resources :doctor_schedules
    resources :appointments, only: [ :index, :show ]
    resources :blog_posts
    resources :pages
    resources :testimonials
    resources :contact_submissions, only: [ :index, :show, :update ]
    resources :leads, only: [ :index, :show, :update ] do
      member do
        patch :move
        post :draft_reply
      end
      resources :lead_activities, only: [ :create ]
    end
    resources :lab_tests
    resources :visits, only: [ :index, :show ]
    resources :dialysis_machines
    resources :dialysis_stations
    resources :dialysis_consumables
    resources :transplant_waitlist_entries
    resources :patient_surveys, only: [:index, :show, :destroy]
    get "analytics", to: "analytics#index", as: :analytics
    get "revenue", to: "revenue#index", as: :revenue
    get "intelligence", to: "intelligence#index", as: :intelligence
    get "intelligence/patients/:id", to: "intelligence#show", as: :intelligence_patient
  end

  # Shared notifications (authenticated)
  resources :notifications, only: [ :index, :show ] do
    member do
      patch :mark_read
    end
    collection do
      patch :mark_all_read
    end
  end

  # Webhooks
  namespace :webhooks do
    post "paystack", to: "paystack#create"
  end

  # Health check
  get "up" => "rails/health#show", as: :rails_health_check
end
