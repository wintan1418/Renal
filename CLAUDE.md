# Healthroom — Renal Hospital Management System

## Project Overview

A web-based management system for a renal (kidney) hospital in Nigeria. Built as a Rails 8 MVC monolith covering public website, appointment scheduling, patient portal, clinical workflows (EMR-lite), dialysis unit management, billing, and admin analytics.

## Tech Stack

- **Framework**: Ruby on Rails 8.0.4
- **Ruby**: 3.4.3
- **Database**: PostgreSQL
- **CSS**: Tailwind CSS + DaisyUI
- **JavaScript**: Hotwire (Turbo + Stimulus), import maps
- **Asset Pipeline**: Propshaft
- **Auth**: Devise + Pundit (authorization)
- **Background Jobs**: Solid Queue
- **WebSockets**: Solid Cable + Action Cable
- **Caching**: Solid Cache
- **Payments**: Paystack (via Faraday)
- **SMS**: Termii (via Faraday)
- **Search**: pg_search (PostgreSQL full-text)
- **Charts**: Chartkick + Groupdate
- **PDF**: Prawn
- **Currency**: money-rails (NGN)
- **Audit Trail**: audited gem
- **Pagination**: Pagy
- **Calendar**: simple_calendar

## Commands

```bash
# Setup
bin/setup                        # Install deps, prepare DB, clear logs/tmp

# Development
bin/dev                          # Start dev server (Foreman: Rails + Tailwind watcher)
bin/rails server                 # Rails server only (port 3000)
bin/rails console                # Rails console

# Database
bin/rails db:create              # Create databases
bin/rails db:migrate             # Run pending migrations
bin/rails db:seed                # Seed data
bin/rails db:reset               # Drop, create, migrate, seed

# Testing
bin/rails test                   # Run all unit/integration tests
bin/rails test:system            # Run system tests (headless Chrome)
bin/rails test test/models/      # Run model tests only
bin/rails test test/controllers/ # Run controller tests only

# Code Quality
bin/brakeman                     # Security vulnerability scan
bin/rubocop                      # Ruby style linting
bin/rubocop -a                   # Auto-fix style issues

# Background Jobs
bin/jobs                         # Start Solid Queue worker

# Generators
bin/rails generate model Name    # Generate model + migration
bin/rails generate controller Ns::Name  # Generate namespaced controller
```

## Architecture

### User Roles (enum on User model)
- `patient` (0) — Books appointments, views medical records, pays invoices
- `receptionist` (1) — Manages front desk, check-ins, walk-ins, billing
- `nurse` (2) — Records vitals, assists with dialysis sessions
- `doctor` (3) — Writes clinical notes, orders labs, prescribes, manages visits
- `admin` (4) — Full system access, user management, analytics

### Controller Namespaces
- `Public::` — Public website (no auth required)
- `PatientPortal::` — Patient-facing dashboard (role: patient)
- `Staff::` — Clinical workflows (roles: doctor, nurse)
- `Receptionist::` — Front desk operations (role: receptionist)
- `Admin::` — System administration (role: admin)
- `Webhooks::` — External webhook receivers (Paystack)

### Key Patterns
- **Service Objects**: `app/services/` — Complex business logic follows `ApplicationService.call(...)` pattern
- **Pundit Policies**: `app/policies/` — Per-model authorization policies
- **Turbo Frames**: Partial page updates (booking wizard, tabbed views, modals)
- **Turbo Streams**: Real-time broadcasts (notifications, queue board, messaging)
- **Background Jobs**: `app/jobs/` — Solid Queue for async work (reminders, SMS, PDF generation)
- **Money**: All monetary values stored as integer cents (kobo), displayed via money-rails

### Database Conventions
- All prices/amounts use `_cents` suffix (integer, stored in kobo)
- Status fields use integer enums
- Soft deletes use `active` boolean (not paranoia/discard)
- Timestamps always present
- Foreign keys use `_id` suffix
- Medical Record Numbers (MRN) auto-generated for patients

### File Organization
```
app/
  controllers/
    public/           # Public website
    patient_portal/   # Patient dashboard
    staff/            # Doctor/nurse workflows
    receptionist/     # Front desk
    admin/            # Administration
    webhooks/         # External webhooks
  models/             # ActiveRecord models
  views/
    layouts/          # public, dashboard, minimal
    shared/           # Reusable partials (navbar, sidebar, flash, etc.)
  services/           # Service objects (business logic)
  policies/           # Pundit authorization policies
  jobs/               # Background jobs
  mailers/            # Email templates
  channels/           # Action Cable channels
  javascript/
    controllers/      # Stimulus controllers
```

### Testing Conventions
- Test framework: Minitest (Rails default)
- Factories: FactoryBot
- Fake data: Faker
- HTTP mocking: WebMock + VCR
- Coverage: SimpleCov
- Run `bin/rails test` before committing

## Environment Variables (Production)

```
DATABASE_URL          # PostgreSQL connection string
RAILS_MASTER_KEY      # Credentials decryption key
PAYSTACK_SECRET_KEY   # Paystack API secret
PAYSTACK_PUBLIC_KEY   # Paystack public key
TERMII_API_KEY        # Termii SMS API key
TERMII_SENDER_ID      # Termii sender ID
```

## Documentation

- `docs/ARCHITECTURE.md` — Full system architecture, database schema, and implementation phases
