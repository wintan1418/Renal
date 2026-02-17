# Healthroom — Testing Guide

## Starting the App

```bash
bin/dev          # starts Rails + CSS watcher (recommended)
# or
bin/rails server # Rails only
```

Visit: http://localhost:3000

---

## Login Credentials

All passwords: **`password123`**

| Role         | Email                            | Notes                              |
|--------------|----------------------------------|------------------------------------|
| Admin        | admin@healthroom.ng              | Full system access                 |
| Doctor       | adaeze.okonkwo@healthroom.ng     | Nephrologist — has patients        |
| Doctor       | oluwaseun.adeleke@healthroom.ng  | Dialysis specialist                |
| Nurse        | nurse.johnson@healthroom.ng      | Dialysis unit                      |
| Receptionist | receptionist@healthroom.ng       | Front desk                         |
| Patient      | patient@healthroom.ng            | Tunde Bakare — CKD Stage 3a        |
| Patient      | ngozi.obi@healthroom.ng          | Ngozi Obi — ESRD, on dialysis      |
| Patient      | musa.aliyu@healthroom.ng         | Musa Aliyu — CKD Stage 2, new      |

---

## Public Website (no login required)

| URL                       | What to check                                  |
|---------------------------|------------------------------------------------|
| http://localhost:3000     | Homepage — navy/orange hero, services, doctors |
| /about                    | About page                                     |
| /services                 | Services listing                               |
| /doctors                  | Doctor profiles                                |
| /blog                     | Blog posts (4 articles seeded)                 |
| /contact                  | Contact form — submit to create a submission   |
| /testimonials             | Patient testimonials                           |

---

## Patient Portal — Log in as `patient@healthroom.ng`

### Dashboard
- Should show upcoming appointments (tomorrow + next Wednesday)
- Notification bell should show unread count

### Appointments
- View upcoming: confirmed appointment tomorrow with Dr. Okonkwo
- View past: 2 completed visits
- Book new appointment: select Nephrology → Dr. Okonkwo → pick a date → confirm

### Medical Records
- **Lab Results**: 4 results from baseline panel (Creatinine HIGH, eGFR LOW, Potassium NORMAL, Haemoglobin LOW)
- **Prescriptions**: Active prescription with 4 items (Lisinopril, Furosemide, Calcium Carbonate, Ferrous Sulfate)
- **Medical Records**: Overview of visits and diagnoses

### Billing
- **Invoices**: 2 invoices — one sent (₦50,000 unpaid), one paid (₦35,000)
- **Pay Now** button visible on the unpaid invoice (will redirect to Paystack in production)
- **Payments**: 1 successful cash payment history

### Messages
- Existing conversation with Dr. Okonkwo about Furosemide dizziness
- 3 messages in thread
- Send a new reply

### Notifications
- 3 notifications: welcome, invoice ready, lab results

---

## Patient Portal — Log in as `ngozi.obi@healthroom.ng` (Dialysis Patient)

### Dialysis History
- 5 completed dialysis sessions with fluid removal and weight data
- One session shows complication note
- Charts should render (weight trend, fluid trend)

### Diet & Fluid Tracker
- 14 log entries across 7 days (breakfast + lunch)
- Add a new diet log entry for today

### Emergency Contacts
- 2 contacts: Chidi Obi (Son, primary) and Adaeze Obi-Nwosu (Daughter)
- Edit or add a new contact

### Billing
- Invoice for 3 dialysis sessions (₦150,000 total, ₦50,000 part-paid)
- Insurance claim submitted (Leadway Health)

---

## Staff Portal — Log in as `adaeze.okonkwo@healthroom.ng`

### Dashboard
- Should show today's appointments and recent patients

### Appointments
- List of all appointments; click any to view detail
- Start → Complete workflow buttons visible on in-progress appointments

### Patient Chart (the main clinical workflow)
- Go to Patients → search "Tunde" or "Bakare"
- Click patient → opens chart with tabs:
  - **Demographics**: CKD Stage 3a, blood group O+, allergies (Penicillin, NSAIDs)
  - **Visits**: 2 completed visits with SOAP notes
  - **Vitals**: 6 months of historical BP/weight data
  - **Lab Orders**: 1 completed lab order with 4 results
  - **Prescriptions**: 1 active prescription
  - **Diagnoses**: CKD Stage 3a (primary), Hypertension (secondary)
- From a visit: add new clinical note, new vitals, new lab order, new prescription

### Doctor Schedules
- View and manage availability slots (Mon–Fri 09:00–17:00 already set)

---

## Staff Portal — Log in as `oluwaseun.adeleke@healthroom.ng` (Dialysis Doctor)

### Dialysis Sessions
- Board view: http://localhost:3000/staff/dialysis_sessions/board
- List of sessions for patient Ngozi Obi
- View completed session details (pre/post vitals, fluid removed, machine used)

---

## Receptionist — Log in as `receptionist@healthroom.ng`

### Appointments
- Today's appointments: http://localhost:3000/receptionist/appointments/today
- Queue view: http://localhost:3000/receptionist/appointments/queue
- Walk-in: create new appointment from scratch
- Check-in a patient: find the confirmed appointment and click Check In

### Invoices
- 3 visible invoices (Tunde's unpaid, Ngozi's partial, Musa's draft)
- Draft invoice for Musa — click "Send to Patient"
- Record a cash payment on Tunde's invoice

### Insurance Claims
- Ngozi's claim to Leadway Health — mark as approved

---

## Admin — Log in as `admin@healthroom.ng`

### Dashboard
- Overview stats (users, appointments, revenue)

### Analytics
- http://localhost:3000/admin/analytics
- Charts: patient growth, revenue trend, appointment completion, CKD distribution

### Content Management
- **Blog Posts**: 4 articles — edit, publish, archive
- **Testimonials**: 4 testimonials — approve/unapprove
- **Pages**: CMS pages
- **Contact Submissions**: 2 unread enquiries

### Clinical Catalog
- **Lab Tests**: 33 tests with normal ranges and prices
- **Departments**: 7 departments
- **Services**: 13 services

### Dialysis Unit Management
- **Machines**: 3 machines (2 available, 1 in maintenance)
- **Stations**: 8 stations (6 chairs, 2 beds)
- **Consumables**: 10 consumables (check: AV Fistula Needles 16G is below reorder level — qty 8, reorder 50)

### Transplant Waitlist
- Ngozi Obi — listed 6 months ago, blood group A+, PRA 15.5%, active/standard priority

### Patient Surveys
- 4 surveys (2 from Tunde, 1 from Ngozi)
- Average ratings visible

### User Management
- 13 users total — view, edit roles, activate/deactivate

---

## Key Flows to Test End-to-End

### 1. Full Appointment Flow
1. Log in as **patient@healthroom.ng** → Book a new appointment
2. Log in as **receptionist@healthroom.ng** → Check in the patient
3. Log in as **adaeze.okonkwo@healthroom.ng** → Start appointment → write SOAP note → complete
4. Log in as **receptionist@healthroom.ng** → Create invoice from visit → send to patient
5. Log in as **patient@healthroom.ng** → View invoice → click Pay Now

### 2. Dialysis Session Flow
1. Log in as **nurse.johnson@healthroom.ng** → View dialysis sessions board
2. View an existing completed session for Ngozi Obi
3. Log in as **ngozi.obi@healthroom.ng** → Check dialysis history, add diet log

### 3. Admin Content Flow
1. Log in as **admin@healthroom.ng** → Create a new blog post → publish
2. Go to Contact Submissions → reply to an enquiry
3. View analytics dashboard

---

## Reset & Re-seed

To wipe and re-seed from scratch:
```bash
bin/rails db:reset db:seed
```

To re-seed without wiping (idempotent — safe to run multiple times):
```bash
bin/rails db:seed
```
