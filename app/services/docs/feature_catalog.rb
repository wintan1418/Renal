module Docs
  # Single source of truth for the feature document — rendered both as the
  # /document HTML page and the downloadable PDF. Text is ASCII-safe so it
  # renders cleanly in Prawn's built-in fonts.
  class FeatureCatalog
    def self.sections
      [
      { title: "Public website",
        blurb: "Patient-facing marketing site and guided demo.",
        items: [
          "Animated marketing site with real photography (services, doctors, blog, testimonials, contact)",
          "Platform-capabilities sales section (AI, adequacy, monitoring, video, portal)",
          "3-step appointment booking wizard",
          "Guided demo page with one-tap role logins and a role-by-role tour",
          "Scroll-reveal animations, hover interactions, fully responsive"
        ] },
      { title: "Patient portal",
        blurb: "Everything a patient needs, in one private space.",
        items: [
          "Dashboard: upcoming appointments, recent labs, balances",
          "Appointments - book, view, cancel with a status timeline",
          "Lab results with trends and an AI plain-language explanation",
          "Prescriptions, dialysis history and medical records",
          "Diet & fluid tracker with an AI diet coach",
          "Health Assistant - AI triage chatbot that escalates red flags",
          "Home monitoring (RPM) - daily BP, weight, pulse and medication check-ins",
          "Video consultations - one-tap, no app install",
          "Invoices & payments, profile, emergency contacts, secure messaging"
        ] },
      { title: "Clinical workflows (doctor / nurse)",
        blurb: "A real clinical home screen and chart.",
        items: [
          "Rich dashboard: today's schedule, patients needing attention, recent labs, weekly volume",
          "Patient chart: demographics, visits, vitals, diagnoses, allergies, medications, prescriptions, labs",
          "Renal snapshot - eGFR, creatinine, Hb, ferritin, calcium, phosphorus, PTH, potassium vs targets",
          "Vascular access surveillance - fistula/graft/catheter with status lifecycle",
          "AI clinical scribe - rough notes turned into a structured SOAP note",
          "eGFR-adjusted dose calculator - standard / adjust / avoid guidance",
          "Lab results review and critical-result auto-escalation to the ordering clinician"
        ] },
      { title: "Dialysis unit",
        blurb: "Purpose-built dialysis operations.",
        items: [
          "Live unit board with running session timers and auto-refresh",
          "Dialysis adequacy - Kt/V, URR and IDWG per session vs targets (Kt/V >= 1.2, URR >= 65%)",
          "Chair-scheduling optimizer - weekly utilisation by day and shift with free slots",
          "Machines, stations and consumables with usage tracking and reorder alerts"
        ] },
      { title: "Smart Intelligence (admin)",
        blurb: "Predictive analytics over your own data.",
        items: [
          "CKD progression predictor - eGFR trend with projected time to ESRD",
          "At-risk patient ranking, no-show prediction, inventory stock-out forecast",
          "Command-center dashboard - population health, revenue and operations",
          "Ask Your Data - natural-language analytics grounded in a live snapshot"
        ] },
      { title: "Revenue cycle & CRM",
        blurb: "Run the business, not just the clinic.",
        items: [
          "Revenue-cycle dashboard - invoiced/collected/outstanding, collection rate, A/R aging, top debtors",
          "CRM lead pipeline - drag-and-drop Kanban, activity timeline, follow-ups, AI reply drafting",
          "Public contact submissions flow straight in as leads",
          "Invoices, payments and insurance/HMO claims"
        ] },
      { title: "Quality & compliance",
        blurb: "Governance-ready reporting.",
        items: [
          "Quality dashboard - adequacy %, mean Kt/V & URR, completion & no-show rates, lab flags, access status",
          "Downloadable PDF quality report",
          "Full audit trail on clinical records"
        ] },
      { title: "AI layer",
        blurb: "Provider-agnostic, safe by design.",
        items: [
          "OpenAI, Gemini or OpenRouter via RubyLLM - switchable by config",
          "Graceful fallback to rule-based output when no key is set",
          "Powers briefings, scribe, lab explainer, diet coach, triage, CRM replies and analytics"
        ] },
      { title: "Communications",
        blurb: "Reach patients where they are.",
        items: [
          "In-app notifications and secure patient-clinician messaging",
          "SMS appointment reminders (Termii) - active once a key is set",
          "Video telemedicine via embedded Jitsi - no third-party account needed"
        ] },
      { title: "Platform",
        blurb: "Built for real deployment.",
        items: [
          "Five roles (patient, receptionist, nurse, doctor, admin) with tailored dashboards and authorization",
          "Configurable currency, globally-neutral content (no country lock-in)",
          "Cloudinary media, Solid Queue/Cache/Cable, idempotent production-safe seed data"
        ] }
      ]
    end
  end
end
