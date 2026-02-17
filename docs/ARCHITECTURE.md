# Healthroom — System Architecture

## Table of Contents

1. [Overview](#overview)
2. [Tech Stack](#tech-stack)
3. [Architecture Decisions](#architecture-decisions)
4. [Database Schema](#database-schema)
5. [Controller & Route Structure](#controller--route-structure)
6. [Service Objects](#service-objects)
7. [Background Jobs](#background-jobs)
8. [Real-time Features](#real-time-features)
9. [Implementation Phases](#implementation-phases)

---

## Overview

Healthroom is a web-based management system for a renal (kidney) hospital in Nigeria. It is built as a Rails 8 MVC monolith and covers:

- **Public Website**: Hospital info, doctor profiles, blog, contact
- **Appointment Scheduling**: Online booking, recurring dialysis schedules, walk-in queue
- **Patient Portal**: Dashboard, lab results, prescriptions, messaging, invoices
- **Clinical Workflows (EMR-lite)**: Visits, SOAP notes, vitals, lab orders, prescriptions, diagnoses
- **Dialysis Unit Management**: Sessions, machines, stations, consumables, pre/post vitals
- **Billing & Payments**: Invoices, Paystack online payments, insurance/HMO claims
- **Admin Analytics**: Patient volume, revenue, CKD distribution, exports

---

## Tech Stack

| Layer | Technology | Purpose |
|-------|-----------|---------|
| Framework | Rails 8.0.4 | MVC web framework |
| Ruby | 3.4.3 | Language runtime |
| Database | PostgreSQL | Primary data store |
| CSS | Tailwind CSS + DaisyUI | Styling and UI components |
| JavaScript | Hotwire (Turbo + Stimulus) | SPA-like interactions without SPA complexity |
| Asset Pipeline | Propshaft + importmap-rails | Asset serving and JS module loading |
| Auth | Devise | Authentication (confirmable, lockable, recoverable, trackable) |
| Authorization | Pundit | Role-based policy authorization |
| Payments | Paystack via Faraday | Online payments (Nigerian market) |
| SMS | Termii via Faraday | SMS notifications (Nigerian market) |
| Background Jobs | Solid Queue | Database-backed job processing |
| WebSockets | Solid Cable + Action Cable | Real-time updates |
| Caching | Solid Cache | Database-backed fragment caching |
| Search | pg_search | PostgreSQL full-text search |
| Charts | Chartkick + Groupdate | Data visualization |
| PDF | Prawn + prawn-table | Invoice/report PDF generation |
| Currency | money-rails | NGN (Naira) formatting and arithmetic |
| Audit | audited | Automatic model change tracking |
| Pagination | Pagy | Fast record pagination |
| Calendar | simple_calendar | Calendar view rendering |
| File Storage | Active Storage | File uploads (avatars, documents, images) |
| Image Processing | image_processing | Active Storage image variants |

---

## Architecture Decisions

### 1. User Roles: Integer Enum on User Model

```ruby
enum :role, { patient: 0, receptionist: 1, nurse: 2, doctor: 3, admin: 4 }, default: :patient
```

**Rationale**: Single-hospital system where each user has exactly one role. An enum keeps queries trivial and avoids join overhead. Pundit policies handle granular per-action authorization.

- `StaffProfile` holds clinical details (specialization, license, bio, fees) for doctors and nurses
- `PatientProfile` holds medical demographics (MRN, blood group, CKD stage, insurance, next-of-kin)
- This avoids bloating the `users` table while keeping auth simple

### 2. Controller Namespacing (5 Namespaces)

| Namespace | Target Users | Auth Requirement |
|-----------|-------------|-----------------|
| `Public::` | Everyone | None |
| `PatientPortal::` | Patients | Authenticated + patient role |
| `Staff::` | Doctors, Nurses | Authenticated + doctor/nurse role |
| `Receptionist::` | Receptionists | Authenticated + receptionist role |
| `Admin::` | Administrators | Authenticated + admin role |
| `Webhooks::` | External services | API key verification |

Each namespace has a `BaseController` with a `before_action` ensuring the correct role.

### 3. EMR Structure: Visit-Centric

Every clinical interaction follows this data flow:

```
Appointment (scheduled)
  -> Visit (started when patient is seen)
    -> ClinicalNotes (SOAP format)
    -> VitalSigns (BP, weight, temp, etc.)
    -> LabOrders -> LabResults
    -> Prescriptions -> PrescriptionItems
    -> Diagnoses
  -> Invoice (generated from services rendered)
    -> Payments
```

Walk-ins create an ad-hoc appointment first, ensuring every clinical interaction is traceable.

### 4. Recurring Appointments (Dialysis)

Dialysis patients need 2-3 sessions per week on an ongoing basis:

- `RecurringSchedule` defines the pattern (days_of_week array, time, doctor)
- A nightly `RecurringAppointmentGeneratorJob` creates concrete `Appointment` rows for the next 4 weeks
- Each generated appointment links back to its `RecurringSchedule`
- Cancelling one instance does not affect the series

This approach is preferred over iCal RRULE because dialysis scheduling requires concrete slots for machine/chair assignment.

### 5. Notification Architecture (3 Channels)

```
User Action / System Event
  -> NotificationService.dispatch(...)
    -> Notification record (in-app, stored in DB)
    -> Turbo Stream broadcast (real-time browser update)
    -> ActionMailer email (async via Solid Queue)
    -> SMS via TermiiService (async via Solid Queue)
```

`NotificationPreference` lets users control which channels they receive notifications on per notification type.

### 6. Service Objects Pattern

All complex business logic lives in `app/services/`:

```ruby
class ApplicationService
  def self.call(...)
    new(...).call
  end
end

Result = Struct.new(:success, :error, :data, keyword_init: true) do
  def success? = success
  def failure? = !success
end
```

### 7. Money Handling

All monetary values stored as integer cents (kobo) with `_cents` suffix columns. Displayed via money-rails helpers. Default currency: NGN (Nigerian Naira).

---

## Database Schema

### Core Tables

#### hospitals
| Column | Type | Notes |
|--------|------|-------|
| name | string | NOT NULL |
| address | text | |
| city | string | |
| state | string | |
| country | string | default: "Nigeria" |
| phone | string | |
| email | string | |
| website | string | |
| currency | string | default: "NGN" |
| timezone | string | default: "Africa/Lagos" |
| opening_time | time | |
| closing_time | time | |

#### users
| Column | Type | Notes |
|--------|------|-------|
| email | string | NOT NULL, UNIQUE (Devise) |
| encrypted_password | string | NOT NULL (Devise) |
| first_name | string | NOT NULL |
| last_name | string | NOT NULL |
| phone | string | |
| role | integer | NOT NULL, default: 0, enum: patient/receptionist/nurse/doctor/admin |
| active | boolean | default: true |
| *Devise modules* | various | confirmable, lockable, recoverable, trackable |

#### staff_profiles
| Column | Type | Notes |
|--------|------|-------|
| user_id | bigint | NOT NULL, UNIQUE, FK |
| department_id | bigint | FK |
| employee_id | string | UNIQUE |
| specialization | string | e.g., "Nephrology" |
| license_number | string | |
| qualification | string | e.g., "MBBS, FWACP" |
| bio | text | For public profiles |
| consultation_fee_cents | integer | default: 0 |
| available_for_telemedicine | boolean | default: false |
| years_of_experience | integer | |

#### patient_profiles
| Column | Type | Notes |
|--------|------|-------|
| user_id | bigint | NOT NULL, UNIQUE, FK |
| medical_record_number | string | NOT NULL, UNIQUE, auto-generated |
| date_of_birth | date | |
| gender | integer | enum: male/female/other |
| blood_group | integer | enum: A+/A-/B+/B-/AB+/AB-/O+/O- |
| genotype | integer | enum: AA/AS/SS/AC/SC |
| marital_status | integer | enum: single/married/divorced/widowed |
| address, city, state, lga | string/text | Nigerian LGA included |
| nok_name, nok_phone, nok_relationship, nok_address | string/text | Next of kin |
| insurance_provider | string | HMO name |
| insurance_policy_number | string | |
| insurance_expiry_date | date | |
| ckd_stage | integer | enum: stage_1 through stage_5 |
| on_dialysis | boolean | default: false |
| dialysis_start_date | date | |
| transplant_status | integer | enum: none/waitlisted/transplanted |

#### departments
| Column | Type | Notes |
|--------|------|-------|
| name | string | NOT NULL, UNIQUE |
| description | text | |
| head_of_department_id | bigint | FK (users) |
| active | boolean | default: true |

#### services
| Column | Type | Notes |
|--------|------|-------|
| department_id | bigint | FK |
| name | string | NOT NULL |
| description | text | |
| price_cents | integer | NOT NULL, default: 0 |
| duration_minutes | integer | default: 30 |
| service_type | integer | enum: consultation/procedure/lab_test/dialysis/other |
| active | boolean | default: true |

### Appointment Tables

#### doctor_schedules
| Column | Type | Notes |
|--------|------|-------|
| doctor_id | bigint | NOT NULL, FK |
| day_of_week | integer | 0=Sunday..6=Saturday |
| start_time | time | NOT NULL |
| end_time | time | NOT NULL |
| slot_duration_minutes | integer | default: 30 |
| max_patients | integer | default: 20 |
| active | boolean | default: true |

UNIQUE index on `[doctor_id, day_of_week]`

#### schedule_exceptions
| Column | Type | Notes |
|--------|------|-------|
| doctor_id | bigint | NOT NULL, FK |
| exception_date | date | NOT NULL |
| available | boolean | default: false (day off or extra hours) |
| start_time, end_time | time | Only if available=true |
| reason | string | |

#### recurring_schedules
| Column | Type | Notes |
|--------|------|-------|
| patient_id | bigint | NOT NULL, FK |
| doctor_id | bigint | NOT NULL, FK |
| service_id | bigint | FK |
| days_of_week | integer[] | PostgreSQL array, e.g., [1,3,5] |
| start_time | time | NOT NULL |
| start_date | date | NOT NULL |
| end_date | date | NULL = indefinite |
| active | boolean | default: true |

#### appointments
| Column | Type | Notes |
|--------|------|-------|
| patient_id | bigint | NOT NULL, FK |
| doctor_id | bigint | NOT NULL, FK |
| service_id | bigint | FK |
| recurring_schedule_id | bigint | FK (NULL for one-off) |
| department_id | bigint | FK |
| scheduled_date | date | NOT NULL |
| start_time | time | NOT NULL |
| end_time | time | |
| status | integer | enum: pending/confirmed/checked_in/in_progress/completed/cancelled/no_show |
| appointment_type | integer | enum: regular/walk_in/follow_up/emergency/dialysis |
| reason | text | |
| cancellation_reason | text | |
| cancelled_by_id | bigint | FK |
| queue_number | integer | Walk-in queue |
| check_in_time | datetime | |

### Clinical/EMR Tables

#### visits
| Column | Type | Notes |
|--------|------|-------|
| appointment_id | bigint | FK, UNIQUE |
| patient_id | bigint | NOT NULL, FK |
| doctor_id | bigint | NOT NULL, FK |
| visit_date | date | NOT NULL |
| visit_type | integer | enum: outpatient/dialysis/emergency/follow_up |
| chief_complaint | text | |
| status | integer | enum: open/in_progress/completed |

#### clinical_notes
| Column | Type | Notes |
|--------|------|-------|
| visit_id | bigint | NOT NULL, FK |
| author_id | bigint | NOT NULL, FK |
| note_type | integer | enum: soap/progress/discharge/referral |
| subjective | text | S in SOAP |
| objective | text | O in SOAP |
| assessment | text | A in SOAP |
| plan | text | P in SOAP |
| body | text | Free-form (ActionText) |

#### vital_signs
| Column | Type | Notes |
|--------|------|-------|
| visit_id | bigint | FK (nullable for standalone dialysis vitals) |
| patient_id | bigint | NOT NULL, FK |
| recorded_by_id | bigint | NOT NULL, FK |
| dialysis_session_id | bigint | FK |
| measurement_type | integer | enum: pre_visit/post_visit/pre_dialysis/post_dialysis/routine |
| systolic_bp | integer | mmHg |
| diastolic_bp | integer | mmHg |
| heart_rate | integer | bpm |
| temperature | decimal(4,1) | Celsius |
| respiratory_rate | integer | breaths/min |
| oxygen_saturation | decimal(4,1) | SpO2 % |
| weight_kg | decimal(5,2) | |
| height_cm | decimal(5,1) | |
| blood_sugar | decimal(5,1) | mg/dL |
| recorded_at | datetime | NOT NULL |

#### diagnoses
| Column | Type | Notes |
|--------|------|-------|
| patient_id | bigint | NOT NULL, FK |
| visit_id | bigint | FK |
| diagnosed_by_id | bigint | FK |
| icd_code | string | ICD-10 code |
| description | string | NOT NULL |
| diagnosis_type | integer | enum: primary/secondary/comorbidity |
| status | integer | enum: active/resolved/chronic |
| onset_date | date | |
| resolved_date | date | |

#### allergies
| Column | Type | Notes |
|--------|------|-------|
| patient_id | bigint | NOT NULL, FK |
| allergen | string | NOT NULL |
| reaction | string | |
| severity | integer | enum: mild/moderate/severe/life_threatening |

#### medications (current list)
| Column | Type | Notes |
|--------|------|-------|
| patient_id | bigint | NOT NULL, FK |
| name | string | NOT NULL |
| dosage | string | |
| frequency | string | |
| route | string | |
| prescribing_doctor_id | bigint | FK |
| start_date, end_date | date | |
| active | boolean | default: true |

#### lab_tests (catalog)
| Column | Type | Notes |
|--------|------|-------|
| name | string | NOT NULL |
| code | string | UNIQUE |
| category | integer | enum: renal/hematology/biochemistry/urinalysis/serology/other |
| unit | string | e.g., "mg/dL" |
| normal_range_min | decimal(10,3) | |
| normal_range_max | decimal(10,3) | |
| price_cents | integer | default: 0 |
| active | boolean | default: true |

#### lab_orders
| Column | Type | Notes |
|--------|------|-------|
| visit_id | bigint | FK |
| patient_id | bigint | NOT NULL, FK |
| ordered_by_id | bigint | NOT NULL, FK |
| order_date | datetime | NOT NULL |
| status | integer | enum: pending/sample_collected/processing/completed/cancelled |
| priority | integer | enum: routine/urgent/stat |

#### lab_results
| Column | Type | Notes |
|--------|------|-------|
| lab_order_id | bigint | NOT NULL, FK |
| lab_test_id | bigint | NOT NULL, FK |
| patient_id | bigint | NOT NULL, FK |
| value | string | Text result |
| numeric_value | decimal(10,3) | For trend charting |
| unit | string | |
| flag | integer | enum: normal/low/high/critical_low/critical_high |
| reference_range | string | |
| performed_by_id | bigint | FK |
| verified_by_id | bigint | FK |
| result_date | datetime | |

Key index: `[patient_id, lab_test_id, created_at]` for trend queries

#### prescriptions
| Column | Type | Notes |
|--------|------|-------|
| visit_id | bigint | NOT NULL, FK |
| patient_id | bigint | NOT NULL, FK |
| prescribed_by_id | bigint | NOT NULL, FK |
| prescription_date | date | NOT NULL |
| status | integer | enum: active/dispensed/cancelled |

#### prescription_items
| Column | Type | Notes |
|--------|------|-------|
| prescription_id | bigint | NOT NULL, FK |
| medication_name | string | NOT NULL |
| dosage | string | |
| frequency | string | |
| duration | string | |
| route | string | |
| quantity | integer | |
| instructions | text | |

### Dialysis Tables

#### dialysis_machines
| Column | Type | Notes |
|--------|------|-------|
| name | string | NOT NULL |
| serial_number | string | UNIQUE |
| model | string | |
| manufacturer | string | |
| status | integer | enum: available/in_use/maintenance/out_of_service |
| last_maintenance_date | date | |
| next_maintenance_date | date | |

#### dialysis_stations
| Column | Type | Notes |
|--------|------|-------|
| name | string | NOT NULL |
| station_type | integer | enum: bed/chair |
| status | integer | enum: available/occupied/cleaning/out_of_service |

#### dialysis_sessions
| Column | Type | Notes |
|--------|------|-------|
| appointment_id | bigint | FK |
| patient_id | bigint | NOT NULL, FK |
| doctor_id | bigint | NOT NULL, FK |
| nurse_id | bigint | FK |
| dialysis_machine_id | bigint | FK |
| dialysis_station_id | bigint | FK |
| session_type | integer | enum: hemodialysis/peritoneal_dialysis |
| session_date | date | NOT NULL |
| scheduled_start_time | time | |
| actual_start_time, actual_end_time | datetime | |
| duration_minutes | integer | |
| status | integer | enum: scheduled/in_progress/completed/cancelled/interrupted |
| pre_weight_kg, post_weight_kg, dry_weight_kg | decimal(5,2) | |
| fluid_removed_ml | integer | |
| target_fluid_removal_ml | integer | |
| blood_flow_rate | integer | mL/min |
| dialysate_flow_rate | integer | mL/min |
| heparin_dose | string | |
| access_type | integer | enum: fistula/graft/catheter |
| access_site | string | |
| pre_systolic_bp, pre_diastolic_bp | integer | |
| post_systolic_bp, post_diastolic_bp | integer | |
| complications | text | |
| nursing_notes, doctor_notes | text | |

#### dialysis_consumables
| Column | Type | Notes |
|--------|------|-------|
| name | string | NOT NULL |
| category | string | |
| unit_of_measure | string | |
| quantity_in_stock | integer | default: 0 |
| reorder_level | integer | default: 10 |
| unit_cost_cents | integer | default: 0 |
| active | boolean | default: true |

#### dialysis_consumable_usages
| Column | Type | Notes |
|--------|------|-------|
| dialysis_session_id | bigint | NOT NULL, FK |
| dialysis_consumable_id | bigint | NOT NULL, FK |
| quantity_used | integer | NOT NULL, default: 1 |
| recorded_by_id | bigint | FK |

### Billing Tables

#### invoices
| Column | Type | Notes |
|--------|------|-------|
| patient_id | bigint | NOT NULL, FK |
| visit_id | bigint | FK |
| invoice_number | string | NOT NULL, UNIQUE, auto-generated |
| invoice_date | date | NOT NULL |
| due_date | date | |
| subtotal_cents | integer | NOT NULL, default: 0 |
| discount_cents | integer | default: 0 |
| tax_cents | integer | default: 0 |
| total_cents | integer | NOT NULL, default: 0 |
| amount_paid_cents | integer | default: 0 |
| status | integer | enum: draft/sent/partially_paid/paid/overdue/cancelled/refunded |
| created_by_id | bigint | FK |

#### invoice_items
| Column | Type | Notes |
|--------|------|-------|
| invoice_id | bigint | NOT NULL, FK |
| service_id | bigint | FK |
| description | string | NOT NULL |
| quantity | integer | NOT NULL, default: 1 |
| unit_price_cents | integer | NOT NULL |
| total_cents | integer | NOT NULL |

#### payments
| Column | Type | Notes |
|--------|------|-------|
| invoice_id | bigint | NOT NULL, FK |
| patient_id | bigint | NOT NULL, FK |
| amount_cents | integer | NOT NULL |
| payment_method | integer | enum: cash/card/bank_transfer/paystack/insurance |
| payment_reference | string | |
| paystack_reference | string | |
| paystack_status | string | |
| status | integer | enum: pending/successful/failed/refunded |
| paid_at | datetime | |
| received_by_id | bigint | FK |

#### insurance_claims
| Column | Type | Notes |
|--------|------|-------|
| invoice_id | bigint | NOT NULL, FK |
| patient_id | bigint | NOT NULL, FK |
| provider_name | string | NOT NULL |
| policy_number | string | |
| claim_amount_cents | integer | NOT NULL |
| approved_amount_cents | integer | |
| status | integer | enum: submitted/under_review/approved/partially_approved/denied/paid |
| submitted_at, resolved_at | datetime | |
| denial_reason | text | |

### Notification & Messaging Tables

#### notifications
| Column | Type | Notes |
|--------|------|-------|
| recipient_id | bigint | NOT NULL, FK |
| actor_id | bigint | FK |
| notifiable_type | string | Polymorphic |
| notifiable_id | bigint | Polymorphic |
| action | string | e.g., "appointment.reminder" |
| title | string | |
| body | text | |
| read_at | datetime | NULL = unread |
| channels_delivered | string[] | PostgreSQL array |

#### notification_preferences
| Column | Type | Notes |
|--------|------|-------|
| user_id | bigint | NOT NULL, FK |
| notification_type | string | NOT NULL |
| email_enabled | boolean | default: true |
| sms_enabled | boolean | default: true |
| in_app_enabled | boolean | default: true |

UNIQUE index on `[user_id, notification_type]`

#### conversations
| Column | Type | Notes |
|--------|------|-------|
| patient_id | bigint | NOT NULL, FK |
| subject | string | |
| status | integer | enum: open/closed |

#### conversation_participants
| Column | Type | Notes |
|--------|------|-------|
| conversation_id | bigint | NOT NULL, FK |
| user_id | bigint | NOT NULL, FK |

#### messages
| Column | Type | Notes |
|--------|------|-------|
| conversation_id | bigint | NOT NULL, FK |
| sender_id | bigint | NOT NULL, FK |
| body | text | NOT NULL |
| read_at | datetime | |

### Content Management Tables

#### pages
| Column | Type | Notes |
|--------|------|-------|
| title | string | NOT NULL |
| slug | string | NOT NULL, UNIQUE |
| body | text | ActionText |
| meta_description | text | SEO |
| published | boolean | default: false |
| author_id | bigint | FK |

#### blog_posts
| Column | Type | Notes |
|--------|------|-------|
| title | string | NOT NULL |
| slug | string | NOT NULL, UNIQUE |
| excerpt | text | |
| body | text | ActionText |
| author_id | bigint | NOT NULL, FK |
| category | integer | enum: kidney_health/nutrition/dialysis_tips/transplant/general_health/news |
| status | integer | enum: draft/published/archived |
| published_at | datetime | |
| views_count | integer | default: 0 |

#### testimonials
| Column | Type | Notes |
|--------|------|-------|
| patient_name | string | NOT NULL |
| content | text | NOT NULL |
| rating | integer | 1-5 |
| approved | boolean | default: false |

#### contact_submissions
| Column | Type | Notes |
|--------|------|-------|
| name | string | NOT NULL |
| email | string | NOT NULL |
| phone | string | |
| subject | string | |
| message | text | NOT NULL |
| status | integer | enum: unread/read/responded |
| responded_by_id | bigint | FK |
| response_notes | text | |

### Extras Tables (Phase 6)

#### telemedicine_sessions
- appointment_id, patient_id, doctor_id, room_id, status, started_at, ended_at

#### patient_surveys
- patient_id, visit_id, overall_rating, doctor_rating, staff_rating, facility_rating, wait_time_rating, comments, would_recommend

#### transplant_waitlist_entries
- patient_id, listed_date, blood_group, status (active/suspended/transplanted/removed), priority, pra_level

#### diet_logs
- patient_id, log_date, meal_type, description, fluid_intake_ml, sodium_mg, potassium_mg, phosphorus_mg, protein_g

#### emergency_contacts
- patient_id, name, phone, relationship, is_primary

---

## Controller & Route Structure

### Route Namespaces

```ruby
Rails.application.routes.draw do
  # Authentication
  devise_for :users, controllers: {
    registrations: "users/registrations",
    sessions: "users/sessions"
  }

  # Public Website
  root "public/home#index"
  scope module: :public do
    get "about", to: "home#about"
    get "services", to: "home#services"
    get "contact", to: "contact#new"
    post "contact", to: "contact#create"
    resources :doctors, only: [:index, :show]
    resources :blog, only: [:index, :show], controller: "blog_posts"
    resources :testimonials, only: [:index]
  end

  # Patient Portal
  namespace :patient_portal do
    root "dashboard#index"
    resources :appointments, only: [:index, :new, :create, :show] do
      member { patch :cancel }
    end
    resources :lab_results, only: [:index, :show]
    resources :prescriptions, only: [:index, :show]
    resources :invoices, only: [:index, :show] do
      member { post :pay }
    end
    resource :medical_record, only: [:show]
    resources :messages, only: [:index, :show, :new, :create]
    resources :diet_logs, except: [:destroy]
    resources :emergency_contacts
    resource :profile, only: [:show, :edit, :update]
    resources :surveys, only: [:new, :create]
    resource :telemedicine, only: [:show], controller: "telemedicine"
    resources :dialysis_history, only: [:index, :show]
  end

  # Staff (Doctors + Nurses)
  namespace :staff do
    root "dashboard#index"
    resources :appointments do
      member { patch :check_in; patch :start; patch :complete }
    end
    resources :patients, only: [:index, :show] do
      resources :allergies
      resources :medications
      resources :diagnoses, only: [:index, :new, :create, :edit, :update]
    end
    resources :visits do
      resources :clinical_notes, except: [:destroy]
      resources :vital_signs, only: [:new, :create]
      resources :lab_orders, only: [:new, :create, :show, :update]
      resources :prescriptions, only: [:new, :create, :show]
    end
    resources :lab_results, only: [:new, :create, :edit, :update]
    resources :dialysis_sessions do
      member { patch :start; patch :complete }
      resources :dialysis_vitals, only: [:create]
    end
    resources :messages, only: [:index, :show, :create]
    resources :telemedicine_sessions, only: [:create, :show] do
      member { patch :start; patch :end_session }
    end
  end

  # Receptionist
  namespace :receptionist do
    root "dashboard#index"
    resources :appointments do
      member { patch :check_in; patch :cancel }
    end
    resources :walk_ins, only: [:new, :create]
    resources :patients, only: [:index, :show, :new, :create, :edit, :update]
    resources :invoices do
      resources :payments, only: [:new, :create]
    end
    resources :insurance_claims, except: [:destroy]
  end

  # Admin
  namespace :admin do
    root "dashboard#index"
    resources :users
    resources :departments
    resources :services
    resources :doctor_schedules
    resources :lab_tests
    resources :dialysis_machines
    resources :dialysis_stations
    resources :dialysis_consumables
    resources :blog_posts
    resources :pages
    resources :testimonials
    resources :contact_submissions, only: [:index, :show, :update]
    resources :audit_logs, only: [:index, :show]
    resources :transplant_waitlist, controller: "transplant_waitlist"
    resource :hospital_settings, only: [:show, :edit, :update]
    get "analytics", to: "analytics#index"
    get "analytics/revenue", to: "analytics#revenue"
    get "analytics/appointments", to: "analytics#appointments"
    get "analytics/patients", to: "analytics#patients"
    get "exports/patients", to: "exports#patients"
    get "exports/revenue", to: "exports#revenue"
    get "exports/appointments", to: "exports#appointments"
  end

  # Webhooks
  namespace :webhooks do
    post "paystack", to: "paystack#create"
  end

  # Notifications (shared)
  resources :notifications, only: [:index] do
    collection { patch :mark_all_read }
    member { patch :mark_read }
  end

  # Health check
  get "up" => "rails/health#show", as: :rails_health_check
end
```

---

## Service Objects

### Directory Structure

```
app/services/
  application_service.rb          # Base class with .call pattern
  result.rb                       # Result struct for service returns

  appointments/
    create_service.rb             # Create appointment with availability check
    cancel_service.rb             # Cancel with notifications
    reschedule_service.rb         # Reschedule with availability re-check
    availability_service.rb       # Compute available slots for doctor+date
    recurring_generator_service.rb # Generate appointments from recurring schedules
    check_in_service.rb           # Mark patient as checked in
    queue_service.rb              # Assign walk-in queue numbers

  billing/
    invoice_generator_service.rb  # Create invoice from visit services
    paystack_service.rb           # Paystack API (initialize, verify, webhook)
    receipt_pdf_service.rb        # PDF receipt generation

  dialysis/
    start_session_service.rb      # Start session, assign resources
    complete_session_service.rb   # Complete session, update stock
    assign_resources_service.rb   # Smart machine/station assignment
    consumable_alert_service.rb   # Check reorder levels

  lab_results/
    flag_calculator_service.rb    # Auto-flag abnormal results

  notifications/
    dispatch_service.rb           # Create + broadcast + email + SMS

  messages/
    create_service.rb             # Create message, notify participants

  patients/
    mrn_generator_service.rb      # Auto-generate Medical Record Numbers

  reports/
    pdf_generator_service.rb      # Generic PDF report generation
    excel_export_service.rb       # Excel data export

  sms/
    termii_service.rb             # Termii REST API wrapper

  telemedicine/
    create_room_service.rb        # Provision video room

  analytics/
    dashboard_service.rb          # Pre-compute dashboard metrics
```

---

## Background Jobs

### Recurring Jobs (Solid Queue)

| Job | Schedule | Purpose |
|-----|----------|---------|
| `RecurringAppointmentGeneratorJob` | Daily 2:00 AM | Generate appointments from recurring schedules for next 4 weeks |
| `AppointmentReminderJob` | Every 15 min | Send reminders for appointments in next 24h |
| `OverdueInvoiceJob` | Daily 6:00 AM | Mark overdue invoices, send payment reminders |
| `DialysisConsumableAlertJob` | Daily 7:00 AM | Alert admin when stock below reorder level |
| `AnalyticsSnapshotJob` | Daily 1:00 AM | Pre-compute dashboard analytics |

### Event-Triggered Jobs

| Job | Trigger | Purpose |
|-----|---------|---------|
| `SendAppointmentConfirmationJob` | After booking | Email + SMS confirmation |
| `SendLabResultNotificationJob` | After lab result entry | Notify patient of available results |
| `SendPaymentReminderJob` | After invoice sent | Payment due reminder |
| `SmsDeliveryJob` | Various | Wrap Termii API call |
| `PaystackWebhookProcessorJob` | Paystack webhook | Process payment webhook async |
| `PdfReportGeneratorJob` | Report request | Generate and attach PDF |
| `PostVisitSurveyJob` | 24h after visit | Send satisfaction survey link |

---

## Real-time Features

### Turbo Frames (partial page updates)
- Appointment booking wizard (multi-step form)
- Patient chart tabs (lazy-loaded)
- Walk-in queue table updates
- Modal dialogs for edit forms

### Turbo Streams (real-time broadcasts)
- Notification bell (prepend new notifications)
- Walk-in queue board (append/remove patients)
- Dialysis unit station board (update station status)
- Chat messages (append to conversation)
- Lab result status updates

### Action Cable Channels
- `NotificationChannel` — per-user notification stream
- `ConversationChannel` — per-conversation message stream

---

## Implementation Phases

### Phase 0: Documentation Setup
Create `CLAUDE.md` and `docs/ARCHITECTURE.md`.

### Phase 1: Foundation
Auth (Devise), roles, Pundit policies, public website, admin panel, DaisyUI setup, seed data.

**Gems**: devise, pundit, phonelib, pg_search, pagy, money-rails, audited, image_processing, faker, factory_bot_rails, shoulda-matchers, letter_opener, annotate, bullet, simplecov, webmock

### Phase 2: Appointments & Scheduling
Booking wizard, doctor availability, recurring schedules, walk-in queue, appointment lifecycle.

**Gems**: simple_calendar

### Phase 3: Medical Records & Clinical Workflow
Visits, SOAP notes, vitals, lab orders/results, prescriptions, diagnoses, allergies, medications, patient chart.

**Gems**: chartkick, groupdate

### Phase 4: Dialysis Management
Sessions, machines, stations, consumables, pre/post vitals, unit dashboard, trend charts.

### Phase 5: Billing, Payments & Notifications
Invoices, Paystack, insurance claims, notification system (email+SMS+in-app), messaging.

**Gems**: faraday, prawn, prawn-table, matrix

### Phase 6: Analytics, Extras & Polish
Admin analytics, telemedicine, surveys, transplant waitlist, diet tracker, emergency contacts, exports.

**Gems**: caxlsx
