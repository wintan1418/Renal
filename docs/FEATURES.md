# Healthroom Renal Centre — Feature Overview

A complete, AI-powered management platform for a renal (kidney) hospital and
dialysis unit. Covers the public website, patient portal, clinical workflows,
the dialysis unit, billing, a CRM, quality reporting, and an AI intelligence
layer — for five user roles in one system.

---

## 1. Public website (marketing)
- Animated marketing site with real photography (hero, services, doctors, blog, testimonials, contact).
- **Platform capabilities** sales section showcasing AI, dialysis adequacy, medication safety, home monitoring, video visits and the patient portal.
- 3-step **appointment booking wizard** (service → doctor/date/time → details).
- Doctor directory & profiles, services, blog, testimonials, contact form (feeds the CRM).
- Scroll-reveal animations, hover micro-interactions, fully responsive.
- **Guided demo page** (`/demo`) — animated walkthrough with one-tap demo logins and a role-by-role tour.

## 2. Patient portal
- Dashboard: upcoming appointments, recent labs, balances.
- **Appointments** — book, view, cancel; status timeline.
- **Lab results** — values vs normal ranges, trends, and an **AI plain-language explanation** ("what your results mean").
- **Prescriptions**, **dialysis history**, **medical records**.
- **Diet & fluid tracker** with an **AI diet coach** (renal-aware, cuisine-neutral guidance).
- **Health Assistant** — AI triage chatbot that answers kidney-health questions and escalates red-flag symptoms.
- **Home monitoring (RPM)** — daily blood-pressure, weight, pulse and medication check-ins; 30-day averages and medication-adherence %.
- **Video consultations** — one-tap secure video visits (no app install).
- **Invoices & payments** — view, pay (demo-mode payment with a clear notice; Paystack-ready).
- Profile management, emergency contacts, patient surveys, secure messaging.

## 3. Clinical workflows (doctor / nurse)
- **Rich clinical dashboard** — today's schedule, patients needing attention, recent labs, weekly volume, upcoming.
- **Patient chart** — demographics, visits, vitals, diagnoses, allergies, medications, prescriptions, labs.
  - **Renal snapshot** — latest eGFR, creatinine, Hb, ferritin, calcium, phosphorus, PTH, potassium vs renal targets.
  - **Home-monitoring** card with BP flags and adherence.
  - **Vascular access surveillance** — fistula/graft/catheter tracking with status lifecycle.
- **AI clinical scribe** — turns rough notes into a structured SOAP note in one click.
- **eGFR-adjusted dose calculator** — ~14 renally-cleared/nephrotoxic drugs → standard / adjust / avoid guidance for the patient's eGFR.
- **Lab results review** — pending and completed orders with abnormal counts.
- **Critical-result auto-escalation** — a critical lab instantly notifies the ordering clinician.
- Visits, vital signs, diagnoses, allergies, medications, lab orders, prescriptions.

## 4. Dialysis unit
- **Live unit board** — real-time station status with running session timers, auto-refresh.
- **Dialysis adequacy** — Kt/V (Daugirdas), URR and interdialytic weight gain (IDWG) computed per session against targets (Kt/V ≥ 1.2, URR ≥ 65%).
- **Chair-scheduling optimizer** — weekly utilisation grid by day and shift (morning/afternoon/evening) with free slots and over-capacity flags.
- Machines, stations and consumables management; consumable usage tracking and reorder alerts.

## 5. Smart Intelligence (admin)
- **CKD progression predictor** — eGFR-trend regression with projected time to ESRD and risk tiers.
- **At-risk patient ranking**, **no-show prediction**, **inventory stock-out forecast**.
- **Command-center dashboard** — population health, revenue and operations at a glance.
- **"Ask Your Data"** — a natural-language analytics assistant that answers questions grounded in a live metrics snapshot.

## 6. Revenue cycle & CRM
- **Revenue-cycle dashboard** — invoiced/collected/outstanding, collection rate, A/R aging buckets, top debtors, payment methods, insurance-claim status.
- **CRM lead pipeline** — drag-and-drop Kanban (new → contacted → qualified → booked → converted/lost), activity timeline, assignment, follow-ups, estimated value, and **AI reply drafting**. Public contact submissions flow straight in as leads.
- Invoices, payments, insurance/HMO claims.

## 7. Quality & compliance
- **Quality dashboard** — dialysis adequacy %, mean Kt/V & URR, appointment completion & no-show rates, lab abnormal/critical counts, vascular-access status, population/CKD mix.
- **Downloadable PDF report** for governance/regulatory review.
- Full audit trail on clinical records.

## 8. AI layer
- Provider-agnostic via **RubyLLM** — OpenAI, Gemini, or OpenRouter, switchable with `AI_PROVIDER`.
- **Graceful fallback**: every AI feature degrades to clear rule-based output when no key is configured — nothing ever breaks.
- Cached responses (resilient to a missing cache backend).
- AI features: clinical briefing, SOAP scribe, lab explainer, diet coach, triage chatbot, CRM reply drafter, "Ask Your Data" analyst.

## 9. Communications
- In-app notifications (Turbo-powered), secure patient–clinician messaging.
- **SMS appointment reminders** (Termii) — sends automatically when `TERMII_API_KEY` is set; no-ops cleanly otherwise.
- **Video telemedicine** — embedded Jitsi rooms, no third-party account required.

## 10. Platform
- **Roles**: patient, receptionist, nurse, doctor, admin — each with a tailored dashboard and authorization (Devise + Pundit).
- **Configurable currency** via `DEFAULT_CURRENCY` (USD default; dynamic symbol everywhere).
- **Globally-neutral** content (no country lock-in).
- **Production media** via Cloudinary; background jobs via Solid Queue; caching via Solid Cache; real-time via Solid Cable.
- Idempotent, Faker-free seed data safe to run on every deploy.

---

## Tech stack
Ruby on Rails 8 · PostgreSQL · Hotwire (Turbo + Stimulus) · Tailwind + custom design system · RubyLLM (OpenAI/Gemini/OpenRouter) · Devise + Pundit · Solid Queue/Cache/Cable · money-rails · Prawn (PDF) · Chartkick · Cloudinary · Paystack · Termii · Jitsi.

## Configuration (environment)
| Variable | Purpose |
|---|---|
| `OPENAI_API_KEY` / `GEMINI_API_KEY` / `OPENROUTER_API_KEY` | AI providers (any one) |
| `AI_PROVIDER` | Force a provider (`openai`/`gemini`/`openrouter`) |
| `DEFAULT_CURRENCY` | Currency code (default `usd`) |
| `CLOUDINARY_URL`, `RAILS_STORAGE_SERVICE=cloudinary` | Production media |
| `TERMII_API_KEY`, `TERMII_SENDER_ID` | SMS reminders |
| `PAYSTACK_SECRET_KEY`, `PAYSTACK_PUBLIC_KEY` | Online payments |
| `RAILS_MASTER_KEY`, `DATABASE_URL` | Standard Rails/Hatchbox |
