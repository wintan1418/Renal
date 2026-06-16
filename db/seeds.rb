puts "=" * 60
puts "Seeding Healthroom Renal Centre..."
puts "=" * 60

# ─── HOSPITAL ─────────────────────────────────────────────
puts "\n[1/9] Hospital..."
hospital = Hospital.find_or_create_by!(name: "Healthroom Renal Centre") do |h|
  h.address = "15 Medical Drive, Victoria Island"
  h.city = "Lagos"
  h.state = "Lagos"
  h.country = "Nigeria"
  h.phone = "+234 800 HEALTH"
  h.email = "info@healthroom.ng"
  h.website = "https://healthroom.ng"
  h.currency = "NGN"
  h.timezone = "Africa/Lagos"
  h.opening_time = "08:00"
  h.closing_time = "18:00"
end
puts "  ✓ #{hospital.name}"

# ─── DEPARTMENTS ──────────────────────────────────────────
puts "\n[2/9] Departments & Services..."
departments_data = [
  { name: "Nephrology",          description: "Diagnosis and treatment of kidney diseases including CKD, glomerulonephritis, and kidney stones." },
  { name: "Dialysis Unit",       description: "Hemodialysis and peritoneal dialysis for end-stage renal disease patients." },
  { name: "Laboratory",          description: "Comprehensive renal function tests, hematology, and urinalysis." },
  { name: "Pharmacy",            description: "Dispensing medications and pharmaceutical care for kidney patients." },
  { name: "Nutrition & Dietetics", description: "Specialized dietary planning for CKD patients." },
  { name: "Transplant Unit",     description: "Kidney transplant evaluation, preparation, and post-transplant care." },
  { name: "Emergency",           description: "24/7 emergency care for acute kidney injuries." }
]
departments_data.each do |d|
  Department.find_or_create_by!(name: d[:name]) { |r| r.description = d[:description] }
end
puts "  ✓ #{Department.count} departments"

services_data = [
  { dept: "Nephrology",          name: "Nephrology Consultation",   price: 2_500_000, dur: 30,  type: :consultation },
  { dept: "Nephrology",          name: "Follow-up Consultation",    price: 1_500_000, dur: 20,  type: :consultation },
  { dept: "Nephrology",          name: "Kidney Biopsy",            price: 15_000_000, dur: 60,  type: :procedure },
  { dept: "Dialysis Unit",       name: "Hemodialysis Session",     price: 5_000_000,  dur: 240, type: :dialysis },
  { dept: "Dialysis Unit",       name: "Peritoneal Dialysis Setup",price: 8_000_000,  dur: 120, type: :dialysis },
  { dept: "Laboratory",          name: "Serum Creatinine",         price: 300_000,    dur: 0,   type: :lab_test },
  { dept: "Laboratory",          name: "Complete Blood Count",     price: 500_000,    dur: 0,   type: :lab_test },
  { dept: "Laboratory",          name: "Electrolyte Panel",        price: 400_000,    dur: 0,   type: :lab_test },
  { dept: "Laboratory",          name: "Urinalysis",               price: 200_000,    dur: 0,   type: :lab_test },
  { dept: "Laboratory",          name: "eGFR Test",                price: 350_000,    dur: 0,   type: :lab_test },
  { dept: "Nutrition & Dietetics", name: "Dietary Consultation",   price: 1_000_000,  dur: 45,  type: :consultation },
  { dept: "Transplant Unit",     name: "Transplant Evaluation",    price: 5_000_000,  dur: 60,  type: :consultation },
  { dept: "Emergency",           name: "Emergency Consultation",   price: 3_000_000,  dur: 30,  type: :consultation }
]
services_data.each do |s|
  dept = Department.find_by!(name: s[:dept])
  Service.find_or_create_by!(name: s[:name]) do |r|
    r.department = dept; r.price_cents = s[:price]
    r.duration_minutes = s[:dur]; r.service_type = s[:type]
  end
end
puts "  ✓ #{Service.count} services"

# ─── USERS ────────────────────────────────────────────────
puts "\n[3/9] Users..."

def create_user(attrs)
  user = User.find_or_initialize_by(email: attrs[:email])
  if user.new_record?
    user.assign_attributes(
      first_name: attrs[:first_name], last_name: attrs[:last_name],
      phone: attrs[:phone], password: "password123",
      password_confirmation: "password123", role: attrs[:role],
      confirmed_at: Time.current
    )
    user.save!
    puts "    + #{attrs[:role].upcase}: #{attrs[:email]}"
  end
  user
end

admin = create_user(email: "admin@healthroom.ng", first_name: "System", last_name: "Admin",
                    phone: "+2348000000001", role: :admin)

nephrology    = Department.find_by!(name: "Nephrology")
dialysis_dept = Department.find_by!(name: "Dialysis Unit")

doctors_data = [
  { email: "adaeze.okonkwo@healthroom.ng",     first_name: "Adaeze",      last_name: "Okonkwo",
    phone: "+2348011111001", dept: nephrology,    specialization: "Nephrology",
    qualification: "MBBS, FWACP (Nephrology)", years: 15, fee: 2_500_000,
    bio: "Consultant nephrologist with 15+ years managing CKD and glomerular diseases at LUTH and private practice." },
  { email: "chukwuemeka.nwosu@healthroom.ng",  first_name: "Chukwuemeka", last_name: "Nwosu",
    phone: "+2348011111002", dept: nephrology,    specialization: "Nephrology & Transplant",
    qualification: "MBBS, MSc, FRCP", years: 20, fee: 3_000_000,
    bio: "Kidney transplant specialist trained at Guy's & St Thomas' Hospital London. Leads the Healthroom transplant programme." },
  { email: "fatima.abdullahi@healthroom.ng",   first_name: "Fatima",      last_name: "Abdullahi",
    phone: "+2348011111003", dept: nephrology,    specialization: "Pediatric Nephrology",
    qualification: "MBBS, FMCPaed", years: 12, fee: 2_000_000,
    bio: "Dedicated to treating kidney diseases in children with a focus on nephrotic syndrome and congenital abnormalities." },
  { email: "oluwaseun.adeleke@healthroom.ng",  first_name: "Oluwaseun",   last_name: "Adeleke",
    phone: "+2348011111004", dept: dialysis_dept, specialization: "Dialysis Medicine",
    qualification: "MBBS, FWACP", years: 10, fee: 2_000_000,
    bio: "Heads the dialysis unit ensuring highest standards of care for hemodialysis and peritoneal dialysis patients." }
]

doctors = doctors_data.map do |d|
  u = create_user(email: d[:email], first_name: d[:first_name], last_name: d[:last_name],
                  phone: d[:phone], role: :doctor)
  StaffProfile.find_or_create_by!(user: u) do |sp|
    sp.department = d[:dept]; sp.employee_id = "DR-#{u.id.to_s.rjust(4, '0')}"
    sp.specialization = d[:specialization]; sp.qualification = d[:qualification]
    sp.bio = d[:bio]; sp.years_of_experience = d[:years]
    sp.consultation_fee_cents = d[:fee]
  end
  u
end

nurse = create_user(email: "nurse.johnson@healthroom.ng", first_name: "Grace", last_name: "Johnson",
                    phone: "+2348022222001", role: :nurse)
StaffProfile.find_or_create_by!(user: nurse) do |sp|
  sp.department = dialysis_dept; sp.employee_id = "NR-001"
  sp.specialization = "Dialysis Nursing"; sp.qualification = "RN, BNSc"
  sp.years_of_experience = 8
end

nurse2 = create_user(email: "aminu.ibrahim@healthroom.ng", first_name: "Aminu", last_name: "Ibrahim",
                     phone: "+2348022222002", role: :nurse)
StaffProfile.find_or_create_by!(user: nurse2) do |sp|
  sp.department = nephrology; sp.employee_id = "NR-002"
  sp.specialization = "Nephrology Nursing"; sp.qualification = "RN"
  sp.years_of_experience = 5
end

receptionist = create_user(email: "receptionist@healthroom.ng", first_name: "Blessing", last_name: "Eze",
                           phone: "+2348033333001", role: :receptionist)

# ── Patients ──
patient1 = create_user(email: "patient@healthroom.ng", first_name: "Tunde", last_name: "Bakare",
                       phone: "+2348044444001", role: :patient)
PatientProfile.find_or_create_by!(user: patient1) do |pp|
  pp.date_of_birth = Date.new(1975, 3, 15); pp.gender = :male
  pp.blood_group = :o_positive; pp.genotype = :aa
  pp.marital_status = :married
  pp.address = "42 Broad Street, Lagos Island"; pp.city = "Lagos"
  pp.state = "Lagos"; pp.lga = "Lagos Island"; pp.occupation = "Business Owner"
  pp.nok_name = "Yemi Bakare"; pp.nok_phone = "+2348044444002"; pp.nok_relationship = "Wife"
  pp.insurance_provider = "NHIS"; pp.insurance_policy_number = "NHIS-TBK-2023-001"
  pp.ckd_stage = :stage_3a; pp.on_dialysis = false
end

patient2 = create_user(email: "ngozi.obi@healthroom.ng", first_name: "Ngozi", last_name: "Obi",
                       phone: "+2348044444010", role: :patient)
PatientProfile.find_or_create_by!(user: patient2) do |pp|
  pp.date_of_birth = Date.new(1968, 8, 22); pp.gender = :female
  pp.blood_group = :a_positive; pp.genotype = :as_genotype
  pp.marital_status = :widowed
  pp.address = "7 Adetokunbo Ademola Crescent, Wuse 2"; pp.city = "Abuja"
  pp.state = "FCT"; pp.lga = "Abuja Municipal"; pp.occupation = "Civil Servant"
  pp.nok_name = "Chidi Obi"; pp.nok_phone = "+2348044444011"; pp.nok_relationship = "Son"
  pp.insurance_provider = "Leadway Health"; pp.insurance_policy_number = "LH-NOB-2022-4456"
  pp.ckd_stage = :stage_5; pp.on_dialysis = true
end

patient3 = create_user(email: "musa.aliyu@healthroom.ng", first_name: "Musa", last_name: "Aliyu",
                       phone: "+2348044444020", role: :patient)
PatientProfile.find_or_create_by!(user: patient3) do |pp|
  pp.date_of_birth = Date.new(1990, 11, 5); pp.gender = :male
  pp.blood_group = :b_positive; pp.genotype = :aa
  pp.marital_status = :single
  pp.address = "21 Gowon Estate, Ipaja"; pp.city = "Lagos"
  pp.state = "Lagos"; pp.lga = "Alimosho"; pp.occupation = "Teacher"
  pp.nok_name = "Fatima Aliyu"; pp.nok_phone = "+2348044444021"; pp.nok_relationship = "Mother"
  pp.ckd_stage = :stage_2; pp.on_dialysis = false
end

puts "  ✓ #{User.count} users total"

# ─── CONTENT (Blog, Testimonials) ─────────────────────────
puts "\n[4/9] Content..."
blog_posts = [
  { title: "Understanding Chronic Kidney Disease: What Every Nigerian Should Know",
    excerpt: "CKD affects millions of Nigerians, yet many remain unaware until it reaches advanced stages.",
    body: "Chronic Kidney Disease is a progressive condition where the kidneys gradually lose their ability to filter waste. In Nigeria, CKD is a growing public health concern with diabetes and hypertension as leading causes.\n\nEarly detection through simple blood and urine tests can catch CKD before symptoms appear. If you have diabetes, high blood pressure, or a family history of kidney disease, annual screening is essential.\n\nKey symptoms include fatigue, leg swelling, changes in urination, and persistent itching.",
    category: :kidney_health },
  { title: "Nutrition Tips for Dialysis Patients",
    excerpt: "Proper nutrition is vital for patients undergoing dialysis. Learn what to eat and avoid.",
    body: "Managing your diet while on dialysis is one of the most important steps you can take. Limit sodium to reduce fluid retention, monitor potassium to protect your heart, control phosphorus to keep bones healthy, and ensure adequate protein intake.\n\nWork with our dietitians at Healthroom to create a personalised meal plan that fits your lifestyle.",
    category: :nutrition },
  { title: "What to Expect During Your First Dialysis Session",
    excerpt: "Starting dialysis can feel overwhelming. Here's a guide to prepare you.",
    body: "Your first session at Healthroom is designed to be as comfortable as possible. Our experienced team will explain the procedure and answer every question. The first session is typically shorter — about 2 hours — to let your body adjust. You can read, watch content, or rest while our team monitors you continuously.",
    category: :dialysis_tips },
  { title: "Living Well with CKD: Managing Your Daily Life",
    excerpt: "A CKD diagnosis doesn't mean the end of a full, active life. Here's how to thrive.",
    body: "With the right management, many people with CKD live full and productive lives. Regular monitoring, medication adherence, dietary changes, and staying physically active (within your capacity) all make a significant difference.\n\nMental health is equally important — speak to your care team if you're feeling anxious or depressed.",
    category: :general_health }
]

blog_posts.each do |post|
  BlogPost.find_or_create_by!(title: post[:title]) do |bp|
    bp.author = admin; bp.excerpt = post[:excerpt]; bp.body = post[:body]
    bp.category = post[:category]; bp.status = :published
    bp.published_at = rand(5..60).days.ago
  end
end

[
  { name: "Mrs. A. Okafor",   rating: 5, content: "The care at Healthroom was exceptional. Dr. Okonkwo took time to explain my condition and options. The dialysis unit is clean and the nurses are incredibly kind." },
  { name: "Alhaji M. Ibrahim",rating: 5, content: "After Stage 4 CKD diagnosis I was devastated. The team at Healthroom gave me hope. Their comprehensive approach has significantly improved my quality of life." },
  { name: "Mr. C. Adekunle", rating: 4, content: "I've been on dialysis here for over a year. The staff treats me like family. Modern facilities and I always feel safe during my sessions." },
  { name: "Mrs. B. Uche",    rating: 5, content: "The transplant evaluation process was thorough and the team kept me informed at every step. Highly recommend Healthroom to anyone with kidney disease." }
].each do |t|
  Testimonial.find_or_create_by!(patient_name: t[:name]) do |r|
    r.content = t[:content]; r.rating = t[:rating]; r.approved = true
  end
end
puts "  ✓ #{BlogPost.count} blog posts, #{Testimonial.count} testimonials"

# ─── LAB TEST CATALOG ─────────────────────────────────────
puts "\n[5/9] Lab Test Catalog..."
lab_tests_data = [
  { name: "Serum Creatinine",               code: "CREAT",   cat: :renal_function, unit: "mg/dL",        min: 0.6,   max: 1.2,   price: 300_000 },
  { name: "Blood Urea Nitrogen (BUN)",      code: "BUN",     cat: :renal_function, unit: "mg/dL",        min: 7.0,   max: 20.0,  price: 250_000 },
  { name: "eGFR",                           code: "EGFR",    cat: :renal_function, unit: "mL/min/1.73m²",min: 60.0,  max: 120.0, price: 350_000 },
  { name: "Uric Acid",                      code: "URIC",    cat: :renal_function, unit: "mg/dL",        min: 3.5,   max: 7.2,   price: 300_000 },
  { name: "Sodium",                         code: "NA",      cat: :electrolytes,   unit: "mEq/L",        min: 136.0, max: 145.0, price: 200_000 },
  { name: "Potassium",                      code: "K",       cat: :electrolytes,   unit: "mEq/L",        min: 3.5,   max: 5.0,   price: 200_000 },
  { name: "Chloride",                       code: "CL",      cat: :electrolytes,   unit: "mEq/L",        min: 98.0,  max: 106.0, price: 200_000 },
  { name: "Bicarbonate",                    code: "HCO3",    cat: :electrolytes,   unit: "mEq/L",        min: 22.0,  max: 29.0,  price: 200_000 },
  { name: "Calcium",                        code: "CA",      cat: :electrolytes,   unit: "mg/dL",        min: 8.5,   max: 10.5,  price: 250_000 },
  { name: "Phosphorus",                     code: "PHOS",    cat: :electrolytes,   unit: "mg/dL",        min: 2.5,   max: 4.5,   price: 250_000 },
  { name: "Magnesium",                      code: "MG",      cat: :electrolytes,   unit: "mg/dL",        min: 1.7,   max: 2.2,   price: 250_000 },
  { name: "Complete Blood Count (CBC)",     code: "CBC",     cat: :hematology,     unit: nil,            min: nil,   max: nil,   price: 500_000 },
  { name: "Hemoglobin",                     code: "HGB",     cat: :hematology,     unit: "g/dL",         min: 12.0,  max: 17.5,  price: 200_000 },
  { name: "Hematocrit",                     code: "HCT",     cat: :hematology,     unit: "%",            min: 36.0,  max: 50.0,  price: 200_000 },
  { name: "Platelet Count",                 code: "PLT",     cat: :hematology,     unit: "×10³/µL",      min: 150.0, max: 400.0, price: 200_000 },
  { name: "Erythropoietin Level",           code: "EPO",     cat: :hematology,     unit: "mIU/mL",       min: 4.3,   max: 29.0,  price: 800_000 },
  { name: "Urinalysis (Complete)",          code: "UA",      cat: :urinalysis,     unit: nil,            min: nil,   max: nil,   price: 200_000 },
  { name: "Urine Protein",                  code: "UPROT",   cat: :urinalysis,     unit: "mg/dL",        min: 0.0,   max: 14.0,  price: 250_000 },
  { name: "Urine Albumin-Creatinine Ratio", code: "UACR",    cat: :urinalysis,     unit: "mg/g",         min: 0.0,   max: 30.0,  price: 400_000 },
  { name: "Albumin",                        code: "ALB",     cat: :liver_function, unit: "g/dL",         min: 3.5,   max: 5.5,   price: 250_000 },
  { name: "Total Cholesterol",              code: "CHOL",    cat: :lipid_profile,  unit: "mg/dL",        min: 0.0,   max: 200.0, price: 300_000 },
  { name: "Fasting Blood Sugar",            code: "FBS",     cat: :other,          unit: "mg/dL",        min: 70.0,  max: 100.0, price: 200_000 },
  { name: "HbA1c",                          code: "HBA1C",   cat: :other,          unit: "%",            min: 4.0,   max: 5.6,   price: 500_000 },
  { name: "Parathyroid Hormone (PTH)",      code: "PTH",     cat: :other,          unit: "pg/mL",        min: 15.0,  max: 65.0,  price: 700_000 },
  { name: "Vitamin D (25-OH)",              code: "VITD",    cat: :other,          unit: "ng/mL",        min: 30.0,  max: 100.0, price: 600_000 },
  { name: "Iron Studies (Ferritin)",        code: "FER",     cat: :other,          unit: "ng/mL",        min: 12.0,  max: 300.0, price: 500_000 }
]
lab_tests_data.each do |lt|
  LabTest.find_or_create_by!(code: lt[:code]) do |t|
    t.name = lt[:name]; t.category = lt[:cat]; t.unit = lt[:unit]
    t.normal_range_min = lt[:min]; t.normal_range_max = lt[:max]; t.price_cents = lt[:price]
  end
end
puts "  ✓ #{LabTest.count} lab tests"

# ─── SCHEDULES & APPOINTMENTS ─────────────────────────────
puts "\n[6/9] Schedules & Appointments..."
User.where(role: :doctor).find_each do |doc|
  (1..5).each do |day|
    DoctorSchedule.find_or_create_by!(doctor: doc, day_of_week: day) do |ds|
      ds.start_time = "09:00"; ds.end_time = "17:00"
      ds.slot_duration_minutes = 30; ds.max_patients = 16; ds.active = true
    end
  end
end
puts "  ✓ #{DoctorSchedule.count} doctor schedules"

# ─── DEMO / TRANSACTIONAL DATA (seed once) ────────────────
# Everything below uses RELATIVE dates (e.g. 8.weeks.ago) as part of its
# find_or_create_by! key, so re-running on a later calendar day would create
# NEW rows = duplicates. Guard it so it only seeds on a fresh database.
# All the *reference* data above (hospital, departments, services, doctors,
# lab tests, blog posts, testimonials, schedules) stays fully idempotent and
# upserts on every run.
if Appointment.exists? || Invoice.exists?
  puts "  ↻ Demo transactional data already present — skipping (idempotent)."
else

dr1 = User.find_by(email: "adaeze.okonkwo@healthroom.ng")
dr4 = User.find_by(email: "oluwaseun.adeleke@healthroom.ng")
nephrology    = Department.find_by!(name: "Nephrology")
dialysis_dept = Department.find_by!(name: "Dialysis Unit")
consult_svc   = Service.find_by!(name: "Nephrology Consultation")
followup_svc  = Service.find_by!(name: "Follow-up Consultation")
dialysis_svc  = Service.find_by!(name: "Hemodialysis Session")

# Patient 1 appointments
[
  { patient: patient1, doctor: dr1, date: 8.weeks.ago.to_date, time: "09:30", type: :scheduled,  reason: "Initial CKD evaluation", status: :completed },
  { patient: patient1, doctor: dr1, date: 4.weeks.ago.to_date, time: "10:00", type: :follow_up,  reason: "Medication review - Lisinopril adjustment", status: :completed },
  { patient: patient1, doctor: dr1, date: Date.tomorrow,        time: "10:00", type: :scheduled,  reason: "Routine 4-week kidney function check-up", status: :confirmed },
  { patient: patient1, doctor: dr1, date: Date.current.next_occurring(:wednesday), time: "14:00", type: :follow_up, reason: "Follow-up on medication changes", status: :pending },
].each do |a|
  Appointment.find_or_create_by!(patient: a[:patient], doctor: a[:doctor], scheduled_date: a[:date]) do |apt|
    apt.service = consult_svc; apt.department = nephrology
    apt.start_time = a[:time]; apt.appointment_type = a[:type]
    apt.reason = a[:reason]; apt.status = a[:status]
  end
end

# Patient 2 (dialysis) appointments
[
  { date: 3.months.ago.to_date, status: :completed },
  { date: 10.weeks.ago.to_date, status: :completed },
  { date: 6.weeks.ago.to_date,  status: :completed },
  { date: 3.weeks.ago.to_date,  status: :completed },
  { date: 1.week.ago.to_date,   status: :completed },
  { date: Date.current + 3,     status: :confirmed  }
].each do |a|
  Appointment.find_or_create_by!(patient: patient2, doctor: dr4, scheduled_date: a[:date]) do |apt|
    apt.service = dialysis_svc; apt.department = dialysis_dept
    apt.start_time = "08:00"; apt.appointment_type = :recurring
    apt.reason = "Regular hemodialysis session"; apt.status = a[:status]
  end
end

# Patient 3 appointments
Appointment.find_or_create_by!(patient: patient3, doctor: dr1, scheduled_date: 2.weeks.ago.to_date) do |apt|
  apt.service = consult_svc; apt.department = nephrology
  apt.start_time = "11:00"; apt.appointment_type = :scheduled
  apt.reason = "New patient — elevated creatinine found on routine workup"; apt.status = :completed
end
puts "  ✓ #{Appointment.count} appointments"

# ─── CLINICAL DATA (Phase 3) ──────────────────────────────
puts "\n[7/9] Clinical Data..."

def seed_visit(apt, doctor, visit_type: :outpatient)
  return apt.visit if apt.visit.present?
  Visit.create!(
    appointment: apt, patient: apt.patient, doctor: doctor,
    visit_date: apt.scheduled_date, visit_type: visit_type,
    chief_complaint: apt.reason, status: :completed
  )
end

# ── Patient 1: two completed visits ──
past_apt1 = Appointment.find_by(patient: patient1, status: :completed, scheduled_date: 8.weeks.ago.to_date)
past_apt2 = Appointment.find_by(patient: patient1, status: :completed, scheduled_date: 4.weeks.ago.to_date)

if past_apt1
  v1 = seed_visit(past_apt1, dr1)

  ClinicalNote.find_or_create_by!(visit: v1, note_type: :soap) do |cn|
    cn.author = dr1
    cn.subjective = "Patient presents with fatigue and leg swelling for 3 months. Reports decreased urine output. Diet high in salt. On Lisinopril 10mg daily for 5 years."
    cn.objective = "BP 148/92 mmHg, HR 78 bpm, Temp 36.8°C, Weight 82kg. Bilateral pedal oedema +1. Lungs clear. Heart sounds normal."
    cn.assessment = "CKD Stage 3a (eGFR ~52). Uncontrolled hypertension. Mild fluid overload."
    cn.plan = "1. Increase Lisinopril to 20mg\n2. Add Furosemide 40mg daily\n3. Low-sodium diet education\n4. Renal panel in 4 weeks\n5. Follow-up 1 month"
  end

  VitalSign.find_or_create_by!(visit: v1, patient: patient1) do |vs|
    vs.recorded_by = dr1; vs.measurement_type = :routine
    vs.systolic_bp = 148; vs.diastolic_bp = 92; vs.heart_rate = 78
    vs.temperature = 36.8; vs.weight_kg = 82.0; vs.height_cm = 175.0
    vs.respiratory_rate = 18; vs.oxygen_saturation = 98
    vs.recorded_at = past_apt1.scheduled_date.to_time + 10.hours
  end

  Diagnosis.find_or_create_by!(patient: patient1, description: "Chronic Kidney Disease, Stage 3a") do |d|
    d.visit = v1; d.diagnosed_by = dr1; d.icd_code = "N18.31"
    d.diagnosis_type = :primary; d.status = :chronic; d.onset_date = 2.years.ago.to_date
  end
  Diagnosis.find_or_create_by!(patient: patient1, description: "Essential Hypertension") do |d|
    d.visit = v1; d.diagnosed_by = dr1; d.icd_code = "I10"
    d.diagnosis_type = :secondary; d.status = :chronic; d.onset_date = 5.years.ago.to_date
  end

  lo = LabOrder.find_or_create_by!(visit: v1, patient: patient1) do |lo|
    lo.ordered_by = dr1; lo.status = :completed; lo.priority = :routine
    lo.clinical_notes = "Baseline renal panel"
    lo.completed_at = past_apt1.scheduled_date.to_time + 14.hours
  end
  [
    { code: "CREAT", val: "1.8",  num: 1.8,  flag: :high },
    { code: "EGFR",  val: "52",   num: 52.0, flag: :low },
    { code: "K",     val: "4.8",  num: 4.8,  flag: :normal },
    { code: "HGB",   val: "11.2", num: 11.2, flag: :low }
  ].each do |r|
    test = LabTest.find_by(code: r[:code])
    next unless test
    LabResult.find_or_create_by!(lab_order: lo, lab_test: test, patient: patient1) do |lr|
      lr.value = r[:val]; lr.numeric_value = r[:num]; lr.flag = r[:flag]
      lr.result_date = past_apt1.scheduled_date; lr.resulted_by = dr1
    end
  end

  pres = Prescription.find_or_create_by!(visit: v1, patient: patient1) do |p|
    p.prescribed_by = dr1; p.status = :active; p.notes = "CKD management medications"
  end
  [
    { name: "Lisinopril",      dosage: "20mg",  freq: "Once daily",               route: "oral", dur: "Ongoing", qty: 30 },
    { name: "Furosemide",      dosage: "40mg",  freq: "Once daily (morning)",      route: "oral", dur: "4 weeks", qty: 28 },
    { name: "Calcium Carbonate", dosage: "500mg", freq: "With meals, 3x daily",   route: "oral", dur: "Ongoing", qty: 90 },
    { name: "Ferrous Sulfate", dosage: "325mg", freq: "Once daily",               route: "oral", dur: "3 months", qty: 90 }
  ].each do |item|
    PrescriptionItem.find_or_create_by!(prescription: pres, medication_name: item[:name]) do |pi|
      pi.dosage = item[:dosage]; pi.frequency = item[:freq]
      pi.route = item[:route]; pi.duration = item[:dur]; pi.quantity = item[:qty]
    end
  end
end

if past_apt2
  v2 = seed_visit(past_apt2, dr1)
  ClinicalNote.find_or_create_by!(visit: v2, note_type: :soap) do |cn|
    cn.author = dr1
    cn.subjective = "Patient reports improved leg swelling but still fatigued. BP better controlled. Adherent to medications."
    cn.objective = "BP 132/84 mmHg, HR 74 bpm, Weight 80kg. Oedema reduced to trace. Lungs clear."
    cn.assessment = "CKD Stage 3a — improving with treatment. BP better controlled."
    cn.plan = "1. Continue current medications\n2. Repeat renal panel in 6 weeks\n3. Dietary counselling referral"
  end
  VitalSign.find_or_create_by!(visit: v2, patient: patient1) do |vs|
    vs.recorded_by = dr1; vs.measurement_type = :routine
    vs.systolic_bp = 132; vs.diastolic_bp = 84; vs.heart_rate = 74
    vs.temperature = 36.6; vs.weight_kg = 80.0; vs.height_cm = 175.0
    vs.respiratory_rate = 16; vs.oxygen_saturation = 99
    vs.recorded_at = past_apt2.scheduled_date.to_time + 10.hours
  end
end

# Patient 1 — allergies, current medications, historical vitals
Allergy.find_or_create_by!(patient: patient1, allergen: "Penicillin") do |a|
  a.reaction = "Skin rash, hives"; a.severity = :moderate
end
Allergy.find_or_create_by!(patient: patient1, allergen: "NSAIDs (Ibuprofen)") do |a|
  a.reaction = "Worsens kidney function"; a.severity = :severe
  a.notes = "Contraindicated due to CKD"
end
Medication.find_or_create_by!(patient: patient1, name: "Lisinopril") do |m|
  m.dosage = "20mg"; m.frequency = "Once daily"; m.route = "oral"
  m.start_date = 1.month.ago.to_date; m.prescribed_by = dr1
end
Medication.find_or_create_by!(patient: patient1, name: "Furosemide") do |m|
  m.dosage = "40mg"; m.frequency = "Once daily (morning)"; m.route = "oral"
  m.start_date = 1.month.ago.to_date; m.prescribed_by = dr1
end

6.downto(1) do |n|
  VitalSign.find_or_create_by!(patient: patient1, recorded_at: n.months.ago.beginning_of_month + 10.hours) do |vs|
    vs.recorded_by = dr1; vs.measurement_type = :routine
    vs.systolic_bp = 140 + rand(-8..14); vs.diastolic_bp = 85 + rand(-5..10)
    vs.heart_rate = 72 + rand(-5..10); vs.temperature = 36.5 + (rand(-2..3) * 0.1)
    vs.weight_kg = 80.0 + rand(-2..4); vs.height_cm = 175.0; vs.oxygen_saturation = 97 + rand(0..2)
  end
end

# ── Patient 2: CKD Stage 5, clinical data ──
p2_apt_past = Appointment.find_by(patient: patient2, status: :completed, scheduled_date: 3.months.ago.to_date)
if p2_apt_past
  v3 = seed_visit(p2_apt_past, dr4, visit_type: :dialysis)
  ClinicalNote.find_or_create_by!(visit: v3, note_type: :soap) do |cn|
    cn.author = dr4
    cn.subjective = "ESRD patient established on thrice-weekly hemodialysis. Reports well-being post-dialysis. Minimal residual urine output."
    cn.objective = "Pre-dialysis BP 168/98, post-dialysis 138/88. Pre-weight 72.5kg, post-weight 70.0kg. Fluid removed 2.5L. Access: AV fistula functioning well."
    cn.assessment = "ESRD on maintenance hemodialysis. Adequate dialysis dose. Anaemia — Hb 9.2 g/dL."
    cn.plan = "1. Continue thrice-weekly HD\n2. Erythropoietin 4000 IU SC weekly\n3. Phosphate binder — Calcium Carbonate 500mg TDS\n4. Referral to transplant team"
  end
  Diagnosis.find_or_create_by!(patient: patient2, description: "End-Stage Renal Disease (ESRD)") do |d|
    d.visit = v3; d.diagnosed_by = dr4; d.icd_code = "N18.6"
    d.diagnosis_type = :primary; d.status = :chronic; d.onset_date = 3.years.ago.to_date
  end
  Diagnosis.find_or_create_by!(patient: patient2, description: "Hypertensive Nephropathy") do |d|
    d.visit = v3; d.diagnosed_by = dr4; d.icd_code = "I12.9"
    d.diagnosis_type = :secondary; d.status = :chronic; d.onset_date = 8.years.ago.to_date
  end
end

Allergy.find_or_create_by!(patient: patient2, allergen: "Contrast Dye") do |a|
  a.reaction = "Anaphylaxis"; a.severity = :life_threatening
end
Medication.find_or_create_by!(patient: patient2, name: "Erythropoietin") do |m|
  m.dosage = "4000 IU"; m.frequency = "Once weekly (SC)"; m.route = "subcutaneous"
  m.start_date = 2.years.ago.to_date; m.prescribed_by = dr4
end
Medication.find_or_create_by!(patient: patient2, name: "Calcium Carbonate") do |m|
  m.dosage = "500mg"; m.frequency = "Three times daily with meals"; m.route = "oral"
  m.start_date = 2.years.ago.to_date; m.prescribed_by = dr4
end

# ── Patient 3: new patient visit ──
p3_apt = Appointment.find_by(patient: patient3, status: :completed)
if p3_apt
  v4 = seed_visit(p3_apt, dr1)
  ClinicalNote.find_or_create_by!(visit: v4, note_type: :soap) do |cn|
    cn.author = dr1
    cn.subjective = "34-year-old male, new patient. Creatinine 1.5 mg/dL on routine bloods. Asymptomatic. History of hypertension for 2 years."
    cn.objective = "BP 138/86, HR 80, Weight 78kg, Height 172cm. No oedema. Urinalysis: trace protein."
    cn.assessment = "CKD Stage 2 — early. Hypertension likely causative factor."
    cn.plan = "1. Optimise BP control with Amlodipine 5mg\n2. Annual renal panel monitoring\n3. Low-sodium, high-fluid diet\n4. Repeat eGFR in 3 months"
  end
  VitalSign.find_or_create_by!(visit: v4, patient: patient3) do |vs|
    vs.recorded_by = dr1; vs.measurement_type = :routine
    vs.systolic_bp = 138; vs.diastolic_bp = 86; vs.heart_rate = 80
    vs.temperature = 36.7; vs.weight_kg = 78.0; vs.height_cm = 172.0; vs.oxygen_saturation = 99
    vs.recorded_at = p3_apt.scheduled_date.to_time + 10.hours
  end
end

puts "  ✓ #{Visit.count} visits, #{ClinicalNote.count} clinical notes"
puts "  ✓ #{LabResult.count} lab results, #{Prescription.count} prescriptions"

# ─── DIALYSIS DATA (Phase 4) ──────────────────────────────
puts "\n[8/9] Dialysis..."
m1 = DialysisMachine.find_or_create_by!(serial_number: "NM-2024-001") do |m|
  m.name = "Nipro Surdial X"; m.model = "Surdial-X"; m.manufacturer = "Nipro"; m.status = :available
end
m2 = DialysisMachine.find_or_create_by!(serial_number: "FX-2023-007") do |m|
  m.name = "Fresenius 4008S"; m.model = "4008S"; m.manufacturer = "Fresenius Medical Care"; m.status = :available
end
m3 = DialysisMachine.find_or_create_by!(serial_number: "NM-2022-003") do |m|
  m.name = "Nipro Surdial 55 Plus"; m.model = "Surdial 55 Plus"; m.manufacturer = "Nipro"; m.status = :maintenance
end

(1..6).each { |i| DialysisStation.find_or_create_by!(name: "Chair #{i}") { |s| s.station_type = :chair; s.status = :available } }
(1..2).each { |i| DialysisStation.find_or_create_by!(name: "Bed #{i}")   { |s| s.station_type = :bed;   s.status = :available } }

consumables_data = [
  { name: "High-Flux Dialyzer 1.8m²",    cat: :dialyzer,     unit: "piece", qty: 50,  reorder: 10, cost: 450_000 },
  { name: "Low-Flux Dialyzer 1.4m²",     cat: :dialyzer,     unit: "piece", qty: 30,  reorder: 10, cost: 300_000 },
  { name: "Bloodlines Adult Set",         cat: :bloodlines,   unit: "set",   qty: 100, reorder: 20, cost: 250_000 },
  { name: "AV Fistula Needles 15G",      cat: :needles,      unit: "pair",  qty: 200, reorder: 50, cost: 80_000 },
  { name: "AV Fistula Needles 16G",      cat: :needles,      unit: "pair",  qty: 8,   reorder: 50, cost: 75_000 },
  { name: "Normal Saline 1L",            cat: :solutions,    unit: "bag",   qty: 200, reorder: 50, cost: 40_000 },
  { name: "Dialysate Concentrate A",     cat: :solutions,    unit: "can",   qty: 5,   reorder: 20, cost: 350_000 },
  { name: "Heparin 5000 IU/mL 5mL",    cat: :medications,  unit: "vial",  qty: 100, reorder: 30, cost: 120_000 },
  { name: "Erythropoietin 4000 IU",     cat: :medications,  unit: "vial",  qty: 40,  reorder: 20, cost: 800_000 },
  { name: "Gauze Swabs",                cat: :other,        unit: "pack",  qty: 60,  reorder: 20, cost: 30_000 }
]
consumables_data.each do |c|
  DialysisConsumable.find_or_create_by!(name: c[:name]) do |item|
    item.category = c[:cat]; item.unit = c[:unit]; item.quantity_in_stock = c[:qty]
    item.reorder_level = c[:reorder]; item.unit_cost_cents = c[:cost]; item.active = true
  end
end

dialyzer      = DialysisConsumable.find_by!(name: "High-Flux Dialyzer 1.8m²")
bloodlines    = DialysisConsumable.find_by!(name: "Bloodlines Adult Set")
needles       = DialysisConsumable.find_by!(name: "AV Fistula Needles 15G")
station1      = DialysisStation.find_by!(name: "Chair 1")
station2      = DialysisStation.find_by!(name: "Chair 2")

# Seed 5 completed dialysis sessions for patient2
dialysis_apts = Appointment.where(patient: patient2, status: :completed).order(:scheduled_date)
dialysis_apts.each_with_index do |apt, idx|
  DialysisSession.find_or_create_by!(appointment: apt, patient: patient2) do |ds|
    ds.doctor = dr4; ds.nurse = nurse
    ds.dialysis_machine = [ m1, m2 ].sample
    ds.dialysis_station = [ station1, station2 ].sample
    ds.session_type = :hemodialysis
    ds.session_date = apt.scheduled_date
    ds.start_time = apt.scheduled_date.to_time + 8.hours
    ds.end_time = apt.scheduled_date.to_time + 12.hours
    ds.duration_minutes = 240
    ds.pre_weight_kg  = (71.0 + rand(-1..3)).round(1)
    ds.post_weight_kg = (68.5 + rand(-1..2)).round(1)
    ds.fluid_removed_ml = (2000 + rand(-200..600)).round(-2)
    ds.target_fluid_removal_ml = 2500
    ds.blood_flow_rate = 250 + rand(0..50)
    ds.access_type = :fistula
    ds.pre_systolic_bp = 165 + rand(-10..15); ds.pre_diastolic_bp = 95 + rand(-5..10)
    ds.post_systolic_bp = 138 + rand(-8..12); ds.post_diastolic_bp = 85 + rand(-5..8)
    ds.status = :completed
    ds.complications = idx == 2 ? "Mild hypotension at hour 3, resolved with saline bolus 200mL" : nil
  end
end

# Attach consumable usages to first dialysis session
first_session = DialysisSession.where(patient: patient2).first
if first_session
  DialysisConsumableUsage.find_or_create_by!(dialysis_session: first_session, dialysis_consumable: dialyzer) do |u|
    u.quantity_used = 1
  end
  DialysisConsumableUsage.find_or_create_by!(dialysis_session: first_session, dialysis_consumable: bloodlines) do |u|
    u.quantity_used = 1
  end
  DialysisConsumableUsage.find_or_create_by!(dialysis_session: first_session, dialysis_consumable: needles) do |u|
    u.quantity_used = 1
  end
end

# Historical vitals for patient2 trend
6.downto(1) do |n|
  VitalSign.find_or_create_by!(patient: patient2, recorded_at: n.months.ago.beginning_of_month + 8.hours) do |vs|
    vs.recorded_by = nurse; vs.measurement_type = :pre_dialysis
    vs.systolic_bp = 165 + rand(-12..18); vs.diastolic_bp = 96 + rand(-8..12)
    vs.heart_rate = 80 + rand(-5..10); vs.temperature = 36.6 + (rand(-2..2) * 0.1)
    vs.weight_kg = 72.0 + rand(-2..4); vs.height_cm = 162.0; vs.oxygen_saturation = 96 + rand(0..2)
  end
end

puts "  ✓ #{DialysisSession.count} sessions, #{DialysisMachine.count} machines, #{DialysisConsumable.count} consumables"

# ─── BILLING, PHASE 6, NOTIFICATIONS ──────────────────────
puts "\n[9/9] Billing, Phase 6 & Notifications..."

# Notification Preferences for all users
User.find_each do |u|
  NotificationPreference::TYPES.each do |ntype|
    NotificationPreference.find_or_create_by!(user: u, notification_type: ntype) do |pref|
      pref.email_enabled = true
      pref.sms_enabled = ntype.in?([ "appointment_reminder", "lab_result_ready" ])
      pref.in_app_enabled = true
    end
  end
end
puts "  ✓ #{NotificationPreference.count} notification preferences"

# ── Invoices & Payments ──
# Patient 1 — sent invoice (unpaid)
inv1 = Invoice.find_or_create_by!(invoice_number: "INV-#{Date.current.year}-00001") do |inv|
  inv.patient = patient1; inv.status = :sent
  inv.subtotal_cents = 5_000_000; inv.discount_cents = 0; inv.tax_cents = 0
  inv.total_cents = 5_000_000; inv.amount_paid_cents = 0
  inv.due_date = 30.days.from_now.to_date; inv.notes = "Consultation and lab tests"
end
InvoiceItem.find_or_create_by!(invoice: inv1, description: "Nephrology Consultation") do |item|
  item.quantity = 1; item.unit_price_cents = 2_500_000; item.total_cents = 2_500_000
end
InvoiceItem.find_or_create_by!(invoice: inv1, description: "Kidney Function Panel") do |item|
  item.quantity = 1; item.unit_price_cents = 1_500_000; item.total_cents = 1_500_000
end
InvoiceItem.find_or_create_by!(invoice: inv1, description: "Urinalysis") do |item|
  item.quantity = 1; item.unit_price_cents = 1_000_000; item.total_cents = 1_000_000
end

# Patient 1 — paid invoice (historical)
inv2 = Invoice.find_or_create_by!(invoice_number: "INV-#{Date.current.year - 1}-99999") do |inv|
  inv.patient = patient1; inv.status = :paid
  inv.subtotal_cents = 3_500_000; inv.discount_cents = 0; inv.tax_cents = 0
  inv.total_cents = 3_500_000; inv.amount_paid_cents = 3_500_000
  inv.due_date = 2.months.ago.to_date; inv.notes = "Initial consultation visit"
end
InvoiceItem.find_or_create_by!(invoice: inv2, description: "Nephrology Consultation") do |item|
  item.quantity = 1; item.unit_price_cents = 2_500_000; item.total_cents = 2_500_000
end
InvoiceItem.find_or_create_by!(invoice: inv2, description: "CBC + Urinalysis") do |item|
  item.quantity = 1; item.unit_price_cents = 1_000_000; item.total_cents = 1_000_000
end
Payment.find_or_create_by!(invoice: inv2, patient: patient1) do |p|
  p.amount_cents = 3_500_000; p.payment_method = :cash; p.status = :successful; p.notes = "Paid at reception"
end

# Patient 2 — sent invoice (dialysis)
inv3 = Invoice.find_or_create_by!(invoice_number: "INV-#{Date.current.year}-00010") do |inv|
  inv.patient = patient2; inv.status = :sent
  inv.subtotal_cents = 15_000_000; inv.discount_cents = 0; inv.tax_cents = 0
  inv.total_cents = 15_000_000; inv.amount_paid_cents = 5_000_000
  inv.due_date = 14.days.from_now.to_date; inv.notes = "Three hemodialysis sessions"
end
InvoiceItem.find_or_create_by!(invoice: inv3, description: "Hemodialysis Session x 3") do |item|
  item.quantity = 3; item.unit_price_cents = 5_000_000; item.total_cents = 15_000_000
end
Payment.find_or_create_by!(invoice: inv3, patient: patient2) do |p|
  p.amount_cents = 5_000_000; p.payment_method = :cash; p.status = :successful; p.notes = "Part payment"
end

# Patient 2 — insurance claim
InsuranceClaim.find_or_create_by!(invoice: inv3, patient: patient2) do |c|
  c.provider_name = "Leadway Health"; c.policy_number = "LH-NOB-2022-4456"
  c.claim_amount_cents = 8_000_000; c.status = :submitted
  c.notes = "Submitted via portal. Awaiting approval."
end

# Patient 3 — draft invoice
inv4 = Invoice.find_or_create_by!(invoice_number: "INV-#{Date.current.year}-00020") do |inv|
  inv.patient = patient3; inv.status = :draft
  inv.subtotal_cents = 2_700_000; inv.discount_cents = 0; inv.tax_cents = 0
  inv.total_cents = 2_700_000; inv.amount_paid_cents = 0
  inv.due_date = 30.days.from_now.to_date; inv.notes = "New patient consultation"
end
InvoiceItem.find_or_create_by!(invoice: inv4, description: "Nephrology Consultation") do |item|
  item.quantity = 1; item.unit_price_cents = 2_500_000; item.total_cents = 2_500_000
end
InvoiceItem.find_or_create_by!(invoice: inv4, description: "Urinalysis") do |item|
  item.quantity = 1; item.unit_price_cents = 200_000; item.total_cents = 200_000
end

puts "  ✓ #{Invoice.count} invoices, #{Payment.count} payments"

# ── Notifications ──
[
  { recipient: patient1, action: "created",  title: "Welcome to Healthroom",            body: "Welcome to your patient portal. Book appointments, view lab results, and manage your care here.", notifiable: patient1 },
  { recipient: patient1, action: "sent",     title: "Invoice ##{inv1.invoice_number} Ready", body: "Your invoice of ₦50,000 is ready. Log in to make payment.", notifiable: inv1 },
  { recipient: patient1, action: "resulted", title: "Lab Results Available",            body: "Your kidney function test results are now available. Log in to view.", notifiable: patient1 },
  { recipient: patient2, action: "created",  title: "Welcome to Healthroom",            body: "Your patient portal is ready. View your dialysis history and upcoming sessions here.", notifiable: patient2 },
  { recipient: patient2, action: "reminder", title: "Dialysis Session Tomorrow",        body: "Reminder: Your hemodialysis session is scheduled for tomorrow at 08:00. Please arrive 15 minutes early.", notifiable: patient2 },
  { recipient: dr1,      action: "booked",   title: "New Appointment Booked",           body: "#{patient1.full_name} has booked an appointment for #{Date.tomorrow.strftime('%B %d, %Y')}.", notifiable: patient1 }
].each do |n|
  Notification.find_or_create_by!(recipient: n[:recipient], action: n[:action], title: n[:title]) do |notif|
    notif.body = n[:body]
    notif.notifiable_type = n[:notifiable].class.name
    notif.notifiable_id = n[:notifiable].id
  end
end
puts "  ✓ #{Notification.count} notifications"

# ── Messaging ──
conv1 = Conversation.find_or_create_by!(patient: patient1, subject: "Question about my Furosemide dosage") do |c|
  c.status = :open
end
ConversationParticipant.find_or_create_by!(conversation: conv1, user: patient1)
ConversationParticipant.find_or_create_by!(conversation: conv1, user: dr1)
Message.find_or_create_by!(conversation: conv1, sender: patient1, body: "Hello Doctor, I have been experiencing dizziness after taking Furosemide in the morning. Should I take it after breakfast instead?") { |m| m.created_at = 3.days.ago }
Message.find_or_create_by!(conversation: conv1, sender: dr1, body: "Yes, please take Furosemide with or after breakfast. The dizziness is likely postural hypotension. If symptoms persist please come in. Also monitor your BP daily.") { |m| m.created_at = 2.days.ago }
Message.find_or_create_by!(conversation: conv1, sender: patient1, body: "Thank you Doctor. I will try that. My BP this morning was 130/82.") { |m| m.created_at = 1.day.ago }

conv2 = Conversation.find_or_create_by!(patient: patient2, subject: "Pre-dialysis dietary advice") do |c|
  c.status = :open
end
ConversationParticipant.find_or_create_by!(conversation: conv2, user: patient2)
ConversationParticipant.find_or_create_by!(conversation: conv2, user: dr4)
Message.find_or_create_by!(conversation: conv2, sender: patient2, body: "Doctor, can I eat before my dialysis session or should I fast?") { |m| m.created_at = 2.days.ago }
Message.find_or_create_by!(conversation: conv2, sender: dr4, body: "You can have a light meal 1–2 hours before your session. Avoid high-potassium foods like bananas, oranges, and tomatoes on dialysis days. Limit fluid to 500mL between sessions.") { |m| m.created_at = 1.day.ago }

puts "  ✓ #{Conversation.count} conversations, #{Message.count} messages"

# ── Phase 6: Emergency Contacts ──
[
  { patient: patient1, name: "Yemi Bakare",      phone: "+2348044444002", rel: "Wife",   primary: true },
  { patient: patient1, name: "Seun Bakare",      phone: "+2348044444003", rel: "Brother", primary: false },
  { patient: patient2, name: "Chidi Obi",        phone: "+2348044444011", rel: "Son",    primary: true },
  { patient: patient2, name: "Adaeze Obi-Nwosu", phone: "+2348044444012", rel: "Daughter", primary: false },
  { patient: patient3, name: "Fatima Aliyu",     phone: "+2348044444021", rel: "Mother", primary: true }
].each do |ec|
  EmergencyContact.find_or_create_by!(patient: ec[:patient], name: ec[:name]) do |c|
    c.phone = ec[:phone]; c.relationship = ec[:rel]; c.is_primary = ec[:primary]
  end
end
puts "  ✓ #{EmergencyContact.count} emergency contacts"

# ── Phase 6: Diet Logs (7 days for patient2) ──
meal_types = %w[breakfast lunch dinner snack]
7.downto(1) do |days_ago|
  meal_types.first(2).each do |meal|
    DietLog.find_or_create_by!(patient: patient2, log_date: days_ago.days.ago.to_date, meal_type: meal) do |dl|
      dl.fluid_intake_ml   = rand(150..300)
      dl.sodium_mg         = rand(300..600)
      dl.potassium_mg      = rand(200..400)
      dl.phosphorus_mg     = rand(150..300)
      dl.protein_g         = rand(15..30)
      dl.calories_kcal     = rand(300..600)
      dl.notes             = meal == "breakfast" ? "Oat porridge, low-potassium" : "Rice and grilled fish"
    end
  end
end
puts "  ✓ #{DietLog.count} diet log entries"

# ── Phase 6: Patient Surveys ──
completed_visits = Visit.where(patient: patient1, status: :completed)
completed_visits.each do |visit|
  PatientSurvey.find_or_create_by!(patient: patient1, visit: visit) do |s|
    s.overall_rating = 5; s.doctor_rating = 5; s.staff_rating = 4
    s.comments = "Dr. Okonkwo was very thorough and explained everything clearly. The waiting time was a bit long but the care was excellent."
    s.published = true
  end
end

PatientSurvey.find_or_create_by!(patient: patient2) do |s|
  s.overall_rating = 4; s.doctor_rating = 5; s.staff_rating = 5
  s.comments = "The dialysis team is wonderful. Nurse Grace is very professional and caring. The dialysis unit is clean and comfortable."
  s.published = true
end
puts "  ✓ #{PatientSurvey.count} patient surveys"

# ── Phase 6: Transplant Waitlist ──
TransplantWaitlistEntry.find_or_create_by!(patient: patient2) do |tw|
  tw.listed_date = 6.months.ago.to_date
  tw.blood_group = "A+"
  tw.status = :active; tw.priority = :standard
  tw.pra_level = 15.5
  tw.notes = "Patient is haemodynamically stable on thrice-weekly HD. Good surgical candidate. Awaiting compatible donor."
end
puts "  ✓ #{TransplantWaitlistEntry.count} transplant waitlist entries"

# ── Phase 6: Telemedicine Session ──
TelemedicineSession.find_or_create_by!(patient: patient3, doctor: dr1) do |tm|
  tm.room_id = "HR-TELE-#{SecureRandom.hex(6).upcase}"
  tm.status = :completed
  tm.started_at = 1.week.ago + 11.hours
  tm.ended_at = 1.week.ago + 11.hours + 25.minutes
  tm.notes = "Patient called to discuss blood pressure readings. BP diary reviewed — readings improving. No medication changes needed at this time."
end
puts "  ✓ #{TelemedicineSession.count} telemedicine sessions"

# ── Contact Submissions ──
ContactSubmission.find_or_create_by!(email: "inquirer@example.com") do |cs|
  cs.name = "Emmanuel Okeke"; cs.phone = "+2348099000001"
  cs.subject = "Appointment enquiry"
  cs.message = "Good day, I would like to know if you accept new patients with Stage 3 CKD. My nephrologist in Ibadan has referred me to a specialist centre."
  cs.status = :unread
end
ContactSubmission.find_or_create_by!(email: "mrs.ade@example.com") do |cs|
  cs.name = "Mrs. Adebimpe Adeyemi"; cs.phone = "+2348099000002"
  cs.subject = "Dialysis package enquiry"
  cs.message = "Please can you send me information about your dialysis packages? My father was recently diagnosed with ESRD and we need to know the costs involved."
  cs.status = :unread
end

end # ─── end demo / transactional data guard ───────────────

puts "\n" + "=" * 60
puts "SEED COMPLETE!"
puts "=" * 60
puts ""
puts "User Credentials (all passwords: password123)"
puts "-" * 60
puts "ADMIN        admin@healthroom.ng"
puts "DOCTOR       adaeze.okonkwo@healthroom.ng"
puts "DOCTOR       oluwaseun.adeleke@healthroom.ng"
puts "NURSE        nurse.johnson@healthroom.ng"
puts "RECEPTIONIST receptionist@healthroom.ng"
puts "PATIENT      patient@healthroom.ng          (Tunde Bakare — CKD 3a)"
puts "PATIENT      ngozi.obi@healthroom.ng         (Ngozi Obi — ESRD, on dialysis)"
puts "PATIENT      musa.aliyu@healthroom.ng        (Musa Aliyu — CKD 2, new patient)"
puts "-" * 60
puts "Run: bin/rails server"
puts ""
