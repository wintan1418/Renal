# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.0].define(version: 2026_06_17_000003) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "action_text_rich_texts", force: :cascade do |t|
    t.string "name", null: false
    t.text "body"
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["record_type", "record_id", "name"], name: "index_action_text_rich_texts_uniqueness", unique: true
  end

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.string "service_name", null: false
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "allergies", force: :cascade do |t|
    t.bigint "patient_id", null: false
    t.string "allergen", null: false
    t.string "reaction"
    t.integer "severity", default: 0, null: false
    t.boolean "active", default: true, null: false
    t.text "notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["patient_id", "active"], name: "index_allergies_on_patient_id_and_active"
    t.index ["patient_id"], name: "index_allergies_on_patient_id"
  end

  create_table "appointments", force: :cascade do |t|
    t.bigint "patient_id", null: false
    t.bigint "doctor_id", null: false
    t.bigint "service_id", null: false
    t.bigint "department_id"
    t.bigint "recurring_schedule_id"
    t.date "scheduled_date", null: false
    t.time "start_time", null: false
    t.time "end_time"
    t.integer "status", default: 0, null: false
    t.integer "appointment_type", default: 0, null: false
    t.text "reason"
    t.integer "queue_number"
    t.text "notes"
    t.bigint "checked_in_by_id"
    t.datetime "checked_in_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["checked_in_by_id"], name: "index_appointments_on_checked_in_by_id"
    t.index ["department_id"], name: "index_appointments_on_department_id"
    t.index ["doctor_id", "scheduled_date", "start_time"], name: "idx_appointments_doctor_date_time"
    t.index ["doctor_id"], name: "index_appointments_on_doctor_id"
    t.index ["patient_id", "scheduled_date"], name: "index_appointments_on_patient_id_and_scheduled_date"
    t.index ["patient_id"], name: "index_appointments_on_patient_id"
    t.index ["recurring_schedule_id"], name: "index_appointments_on_recurring_schedule_id"
    t.index ["scheduled_date"], name: "index_appointments_on_scheduled_date"
    t.index ["service_id"], name: "index_appointments_on_service_id"
    t.index ["status"], name: "index_appointments_on_status"
  end

  create_table "audits", force: :cascade do |t|
    t.integer "auditable_id"
    t.string "auditable_type"
    t.integer "associated_id"
    t.string "associated_type"
    t.integer "user_id"
    t.string "user_type"
    t.string "username"
    t.string "action"
    t.text "audited_changes"
    t.integer "version", default: 0
    t.string "comment"
    t.string "remote_address"
    t.string "request_uuid"
    t.datetime "created_at"
    t.index ["associated_type", "associated_id"], name: "associated_index"
    t.index ["auditable_type", "auditable_id", "version"], name: "auditable_index"
    t.index ["created_at"], name: "index_audits_on_created_at"
    t.index ["request_uuid"], name: "index_audits_on_request_uuid"
    t.index ["user_id", "user_type"], name: "user_index"
  end

  create_table "blog_posts", force: :cascade do |t|
    t.string "title", null: false
    t.string "slug", null: false
    t.text "excerpt"
    t.text "body"
    t.bigint "author_id", null: false
    t.integer "category", default: 0
    t.integer "status", default: 0
    t.datetime "published_at"
    t.integer "views_count", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["author_id"], name: "index_blog_posts_on_author_id"
    t.index ["published_at"], name: "index_blog_posts_on_published_at"
    t.index ["slug"], name: "index_blog_posts_on_slug", unique: true
    t.index ["status"], name: "index_blog_posts_on_status"
  end

  create_table "clinical_notes", force: :cascade do |t|
    t.bigint "visit_id", null: false
    t.bigint "author_id", null: false
    t.integer "note_type", default: 0, null: false
    t.text "subjective"
    t.text "objective"
    t.text "assessment"
    t.text "plan"
    t.text "body"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["author_id"], name: "index_clinical_notes_on_author_id"
    t.index ["note_type"], name: "index_clinical_notes_on_note_type"
    t.index ["visit_id"], name: "index_clinical_notes_on_visit_id"
  end

  create_table "contact_submissions", force: :cascade do |t|
    t.string "name", null: false
    t.string "email", null: false
    t.string "phone"
    t.string "subject"
    t.text "message", null: false
    t.integer "status", default: 0
    t.bigint "responded_by_id"
    t.text "response_notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "stage", default: 0, null: false
    t.bigint "assigned_to_id"
    t.date "follow_up_on"
    t.datetime "last_contacted_at"
    t.string "source", default: "website"
    t.integer "estimated_value_cents"
    t.index ["assigned_to_id"], name: "index_contact_submissions_on_assigned_to_id"
    t.index ["follow_up_on"], name: "index_contact_submissions_on_follow_up_on"
    t.index ["responded_by_id"], name: "index_contact_submissions_on_responded_by_id"
    t.index ["stage"], name: "index_contact_submissions_on_stage"
  end

  create_table "conversation_participants", force: :cascade do |t|
    t.bigint "conversation_id", null: false
    t.bigint "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["conversation_id", "user_id"], name: "idx_conv_participants_unique", unique: true
    t.index ["conversation_id"], name: "index_conversation_participants_on_conversation_id"
    t.index ["user_id"], name: "index_conversation_participants_on_user_id"
  end

  create_table "conversations", force: :cascade do |t|
    t.bigint "patient_id", null: false
    t.string "subject", null: false
    t.integer "status", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["patient_id"], name: "index_conversations_on_patient_id"
    t.index ["status"], name: "index_conversations_on_status"
  end

  create_table "departments", force: :cascade do |t|
    t.string "name", null: false
    t.text "description"
    t.bigint "head_of_department_id"
    t.boolean "active", default: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_departments_on_name", unique: true
  end

  create_table "diagnoses", force: :cascade do |t|
    t.bigint "patient_id", null: false
    t.bigint "visit_id"
    t.bigint "diagnosed_by_id"
    t.string "icd_code"
    t.string "description", null: false
    t.integer "diagnosis_type", default: 0, null: false
    t.integer "status", default: 0, null: false
    t.date "onset_date"
    t.date "resolved_date"
    t.text "notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["diagnosed_by_id"], name: "index_diagnoses_on_diagnosed_by_id"
    t.index ["icd_code"], name: "index_diagnoses_on_icd_code"
    t.index ["patient_id", "status"], name: "index_diagnoses_on_patient_id_and_status"
    t.index ["patient_id"], name: "index_diagnoses_on_patient_id"
    t.index ["visit_id"], name: "index_diagnoses_on_visit_id"
  end

  create_table "dialysis_consumable_usages", force: :cascade do |t|
    t.bigint "dialysis_session_id", null: false
    t.bigint "dialysis_consumable_id", null: false
    t.decimal "quantity_used", precision: 10, scale: 2, null: false
    t.text "notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["dialysis_consumable_id"], name: "index_dialysis_consumable_usages_on_dialysis_consumable_id"
    t.index ["dialysis_session_id", "dialysis_consumable_id"], name: "idx_consumable_usages_session_consumable"
    t.index ["dialysis_session_id"], name: "index_dialysis_consumable_usages_on_dialysis_session_id"
  end

  create_table "dialysis_consumables", force: :cascade do |t|
    t.string "name", null: false
    t.integer "category", default: 0, null: false
    t.string "unit", default: "piece", null: false
    t.decimal "quantity_in_stock", precision: 10, scale: 2, default: "0.0", null: false
    t.decimal "reorder_level", precision: 10, scale: 2, default: "0.0", null: false
    t.integer "unit_cost_cents", default: 0, null: false
    t.string "supplier"
    t.text "description"
    t.boolean "active", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["active"], name: "index_dialysis_consumables_on_active"
    t.index ["category"], name: "index_dialysis_consumables_on_category"
  end

  create_table "dialysis_machines", force: :cascade do |t|
    t.string "name", null: false
    t.string "serial_number", null: false
    t.string "model"
    t.string "manufacturer"
    t.integer "status", default: 0, null: false
    t.date "last_serviced_on"
    t.date "next_service_due"
    t.text "notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["serial_number"], name: "index_dialysis_machines_on_serial_number", unique: true
    t.index ["status"], name: "index_dialysis_machines_on_status"
  end

  create_table "dialysis_sessions", force: :cascade do |t|
    t.bigint "appointment_id"
    t.bigint "patient_id", null: false
    t.bigint "doctor_id", null: false
    t.bigint "nurse_id"
    t.bigint "dialysis_machine_id"
    t.bigint "dialysis_station_id"
    t.integer "session_type", default: 0, null: false
    t.integer "status", default: 0, null: false
    t.date "session_date", null: false
    t.time "start_time"
    t.time "end_time"
    t.integer "duration_minutes"
    t.integer "access_type", default: 0
    t.decimal "pre_weight_kg", precision: 5, scale: 2
    t.decimal "post_weight_kg", precision: 5, scale: 2
    t.decimal "dry_weight_kg", precision: 5, scale: 2
    t.decimal "fluid_removed_ml", precision: 8, scale: 2
    t.decimal "target_fluid_removal_ml", precision: 8, scale: 2
    t.decimal "blood_flow_rate", precision: 6, scale: 2
    t.decimal "dialysate_flow_rate", precision: 6, scale: 2
    t.string "dialysate_composition"
    t.decimal "heparin_dose_units", precision: 8, scale: 2
    t.integer "pre_systolic_bp"
    t.integer "pre_diastolic_bp"
    t.integer "pre_heart_rate"
    t.decimal "pre_temperature", precision: 4, scale: 1
    t.integer "post_systolic_bp"
    t.integer "post_diastolic_bp"
    t.integer "post_heart_rate"
    t.decimal "post_temperature", precision: 4, scale: 1
    t.text "complications"
    t.text "nursing_notes"
    t.boolean "patient_tolerated_well", default: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.decimal "pre_urea", precision: 6, scale: 2
    t.decimal "post_urea", precision: 6, scale: 2
    t.decimal "kt_v", precision: 4, scale: 2
    t.decimal "urr", precision: 5, scale: 2
    t.index ["appointment_id"], name: "index_dialysis_sessions_on_appointment_id"
    t.index ["dialysis_machine_id"], name: "index_dialysis_sessions_on_dialysis_machine_id"
    t.index ["dialysis_station_id"], name: "index_dialysis_sessions_on_dialysis_station_id"
    t.index ["doctor_id"], name: "index_dialysis_sessions_on_doctor_id"
    t.index ["nurse_id"], name: "index_dialysis_sessions_on_nurse_id"
    t.index ["patient_id", "session_date"], name: "index_dialysis_sessions_on_patient_id_and_session_date"
    t.index ["patient_id"], name: "index_dialysis_sessions_on_patient_id"
    t.index ["session_date"], name: "index_dialysis_sessions_on_session_date"
    t.index ["status"], name: "index_dialysis_sessions_on_status"
  end

  create_table "dialysis_stations", force: :cascade do |t|
    t.string "name", null: false
    t.integer "station_type", default: 0, null: false
    t.integer "status", default: 0, null: false
    t.text "notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["status"], name: "index_dialysis_stations_on_status"
  end

  create_table "diet_logs", force: :cascade do |t|
    t.bigint "patient_id", null: false
    t.date "log_date", null: false
    t.integer "meal_type", default: 0, null: false
    t.integer "fluid_intake_ml"
    t.decimal "sodium_mg", precision: 8, scale: 2
    t.decimal "potassium_mg", precision: 8, scale: 2
    t.decimal "phosphorus_mg", precision: 8, scale: 2
    t.decimal "protein_g", precision: 8, scale: 2
    t.decimal "calories_kcal", precision: 8, scale: 2
    t.text "notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["patient_id", "log_date", "meal_type"], name: "idx_diet_logs_patient_date_meal", unique: true
    t.index ["patient_id", "log_date"], name: "index_diet_logs_on_patient_id_and_log_date"
    t.index ["patient_id"], name: "index_diet_logs_on_patient_id"
  end

  create_table "doctor_schedules", force: :cascade do |t|
    t.bigint "doctor_id", null: false
    t.integer "day_of_week", null: false
    t.time "start_time", null: false
    t.time "end_time", null: false
    t.integer "slot_duration_minutes", default: 30
    t.integer "max_patients", default: 20
    t.boolean "active", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["doctor_id", "day_of_week"], name: "index_doctor_schedules_on_doctor_id_and_day_of_week", unique: true
    t.index ["doctor_id"], name: "index_doctor_schedules_on_doctor_id"
  end

  create_table "emergency_contacts", force: :cascade do |t|
    t.bigint "patient_id", null: false
    t.string "name", null: false
    t.string "phone", null: false
    t.string "relationship", null: false
    t.boolean "is_primary", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["patient_id"], name: "index_emergency_contacts_on_patient_id"
  end

  create_table "home_readings", force: :cascade do |t|
    t.bigint "patient_id", null: false
    t.date "recorded_on", null: false
    t.integer "systolic_bp"
    t.integer "diastolic_bp"
    t.integer "pulse"
    t.decimal "weight_kg", precision: 5, scale: 2
    t.boolean "meds_taken", default: true, null: false
    t.text "notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["patient_id", "recorded_on"], name: "index_home_readings_on_patient_id_and_recorded_on"
    t.index ["patient_id"], name: "index_home_readings_on_patient_id"
  end

  create_table "hospitals", force: :cascade do |t|
    t.string "name", null: false
    t.text "address"
    t.string "city"
    t.string "state"
    t.string "country", default: "Nigeria"
    t.string "phone"
    t.string "email"
    t.string "website"
    t.string "currency", default: "NGN"
    t.string "timezone", default: "Africa/Lagos"
    t.time "opening_time"
    t.time "closing_time"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "insurance_claims", force: :cascade do |t|
    t.bigint "invoice_id", null: false
    t.bigint "patient_id", null: false
    t.string "provider_name", null: false
    t.string "policy_number"
    t.string "member_id"
    t.integer "claim_amount_cents", default: 0, null: false
    t.integer "approved_amount_cents", default: 0
    t.integer "status", default: 0, null: false
    t.date "submitted_at"
    t.date "responded_at"
    t.text "notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["invoice_id"], name: "index_insurance_claims_on_invoice_id"
    t.index ["patient_id"], name: "index_insurance_claims_on_patient_id"
    t.index ["status"], name: "index_insurance_claims_on_status"
  end

  create_table "invoice_items", force: :cascade do |t|
    t.bigint "invoice_id", null: false
    t.bigint "service_id"
    t.string "description", null: false
    t.integer "quantity", default: 1, null: false
    t.integer "unit_price_cents", default: 0, null: false
    t.integer "total_cents", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["invoice_id"], name: "index_invoice_items_on_invoice_id"
    t.index ["service_id"], name: "index_invoice_items_on_service_id"
  end

  create_table "invoices", force: :cascade do |t|
    t.bigint "patient_id", null: false
    t.bigint "visit_id"
    t.string "invoice_number", null: false
    t.integer "status", default: 0, null: false
    t.integer "subtotal_cents", default: 0, null: false
    t.integer "discount_cents", default: 0, null: false
    t.integer "tax_cents", default: 0, null: false
    t.integer "total_cents", default: 0, null: false
    t.integer "amount_paid_cents", default: 0, null: false
    t.date "due_date"
    t.text "notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["invoice_number"], name: "index_invoices_on_invoice_number", unique: true
    t.index ["patient_id", "status"], name: "index_invoices_on_patient_id_and_status"
    t.index ["patient_id"], name: "index_invoices_on_patient_id"
    t.index ["status"], name: "index_invoices_on_status"
    t.index ["visit_id"], name: "index_invoices_on_visit_id"
  end

  create_table "lab_orders", force: :cascade do |t|
    t.bigint "visit_id"
    t.bigint "patient_id", null: false
    t.bigint "ordered_by_id", null: false
    t.integer "status", default: 0, null: false
    t.integer "priority", default: 0, null: false
    t.text "clinical_notes"
    t.datetime "collected_at"
    t.datetime "completed_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["ordered_by_id"], name: "index_lab_orders_on_ordered_by_id"
    t.index ["patient_id", "created_at"], name: "index_lab_orders_on_patient_id_and_created_at"
    t.index ["patient_id"], name: "index_lab_orders_on_patient_id"
    t.index ["status"], name: "index_lab_orders_on_status"
    t.index ["visit_id"], name: "index_lab_orders_on_visit_id"
  end

  create_table "lab_results", force: :cascade do |t|
    t.bigint "lab_order_id", null: false
    t.bigint "lab_test_id", null: false
    t.bigint "patient_id", null: false
    t.string "value"
    t.decimal "numeric_value", precision: 10, scale: 2
    t.integer "flag", default: 0, null: false
    t.date "result_date"
    t.bigint "resulted_by_id"
    t.text "notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["flag"], name: "index_lab_results_on_flag"
    t.index ["lab_order_id"], name: "index_lab_results_on_lab_order_id"
    t.index ["lab_test_id"], name: "index_lab_results_on_lab_test_id"
    t.index ["patient_id", "lab_test_id", "result_date"], name: "idx_lab_results_patient_test_date"
    t.index ["patient_id"], name: "index_lab_results_on_patient_id"
    t.index ["resulted_by_id"], name: "index_lab_results_on_resulted_by_id"
  end

  create_table "lab_tests", force: :cascade do |t|
    t.string "name", null: false
    t.string "code", null: false
    t.integer "category", default: 0, null: false
    t.string "unit"
    t.decimal "normal_range_min", precision: 10, scale: 2
    t.decimal "normal_range_max", precision: 10, scale: 2
    t.integer "price_cents", default: 0, null: false
    t.text "description"
    t.boolean "active", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["category"], name: "index_lab_tests_on_category"
    t.index ["code"], name: "index_lab_tests_on_code", unique: true
  end

  create_table "lead_activities", force: :cascade do |t|
    t.bigint "contact_submission_id", null: false
    t.bigint "user_id"
    t.integer "kind", default: 0, null: false
    t.text "body"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["contact_submission_id"], name: "index_lead_activities_on_contact_submission_id"
    t.index ["user_id"], name: "index_lead_activities_on_user_id"
  end

  create_table "medications", force: :cascade do |t|
    t.bigint "patient_id", null: false
    t.string "name", null: false
    t.string "dosage"
    t.string "frequency"
    t.string "route"
    t.date "start_date"
    t.date "end_date"
    t.boolean "active", default: true, null: false
    t.bigint "prescribed_by_id"
    t.text "notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["patient_id", "active"], name: "index_medications_on_patient_id_and_active"
    t.index ["patient_id"], name: "index_medications_on_patient_id"
    t.index ["prescribed_by_id"], name: "index_medications_on_prescribed_by_id"
  end

  create_table "messages", force: :cascade do |t|
    t.bigint "conversation_id", null: false
    t.bigint "sender_id", null: false
    t.text "body", null: false
    t.datetime "read_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["conversation_id", "created_at"], name: "index_messages_on_conversation_id_and_created_at"
    t.index ["conversation_id"], name: "index_messages_on_conversation_id"
    t.index ["sender_id"], name: "index_messages_on_sender_id"
  end

  create_table "notification_preferences", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "notification_type", null: false
    t.boolean "email_enabled", default: true, null: false
    t.boolean "sms_enabled", default: false, null: false
    t.boolean "in_app_enabled", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id", "notification_type"], name: "idx_notification_prefs_user_type", unique: true
    t.index ["user_id"], name: "index_notification_preferences_on_user_id"
  end

  create_table "notifications", force: :cascade do |t|
    t.bigint "recipient_id", null: false
    t.bigint "actor_id"
    t.string "notifiable_type"
    t.bigint "notifiable_id"
    t.string "action", null: false
    t.string "title", null: false
    t.text "body"
    t.datetime "read_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["actor_id"], name: "index_notifications_on_actor_id"
    t.index ["notifiable_type", "notifiable_id"], name: "index_notifications_on_notifiable_type_and_notifiable_id"
    t.index ["recipient_id", "read_at"], name: "index_notifications_on_recipient_id_and_read_at"
    t.index ["recipient_id"], name: "index_notifications_on_recipient_id"
  end

  create_table "pages", force: :cascade do |t|
    t.string "title", null: false
    t.string "slug", null: false
    t.text "body"
    t.text "meta_description"
    t.boolean "published", default: false
    t.bigint "author_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["author_id"], name: "index_pages_on_author_id"
    t.index ["slug"], name: "index_pages_on_slug", unique: true
  end

  create_table "patient_profiles", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "medical_record_number", null: false
    t.date "date_of_birth"
    t.integer "gender"
    t.integer "blood_group"
    t.integer "genotype"
    t.integer "marital_status"
    t.text "address"
    t.string "city"
    t.string "state"
    t.string "lga"
    t.string "occupation"
    t.string "religion"
    t.string "nationality", default: "Nigerian"
    t.string "nok_name"
    t.string "nok_phone"
    t.string "nok_relationship"
    t.text "nok_address"
    t.string "insurance_provider"
    t.string "insurance_policy_number"
    t.date "insurance_expiry_date"
    t.integer "ckd_stage"
    t.boolean "on_dialysis", default: false
    t.date "dialysis_start_date"
    t.integer "transplant_status", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["ckd_stage"], name: "index_patient_profiles_on_ckd_stage"
    t.index ["medical_record_number"], name: "index_patient_profiles_on_medical_record_number", unique: true
    t.index ["on_dialysis"], name: "index_patient_profiles_on_on_dialysis"
    t.index ["user_id"], name: "index_patient_profiles_on_user_id", unique: true
  end

  create_table "patient_surveys", force: :cascade do |t|
    t.bigint "patient_id", null: false
    t.bigint "visit_id"
    t.integer "overall_rating", null: false
    t.integer "doctor_rating"
    t.integer "staff_rating"
    t.text "comments"
    t.boolean "published", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["patient_id", "visit_id"], name: "idx_surveys_patient_visit", unique: true
    t.index ["patient_id"], name: "index_patient_surveys_on_patient_id"
    t.index ["visit_id"], name: "index_patient_surveys_on_visit_id"
  end

  create_table "payments", force: :cascade do |t|
    t.bigint "invoice_id", null: false
    t.bigint "patient_id", null: false
    t.integer "amount_cents", null: false
    t.integer "payment_method", default: 0, null: false
    t.integer "status", default: 0, null: false
    t.string "paystack_reference"
    t.string "paystack_access_code"
    t.text "notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["invoice_id", "status"], name: "index_payments_on_invoice_id_and_status"
    t.index ["invoice_id"], name: "index_payments_on_invoice_id"
    t.index ["patient_id"], name: "index_payments_on_patient_id"
    t.index ["paystack_reference"], name: "index_payments_on_paystack_reference", unique: true, where: "(paystack_reference IS NOT NULL)"
    t.index ["status"], name: "index_payments_on_status"
  end

  create_table "prescription_items", force: :cascade do |t|
    t.bigint "prescription_id", null: false
    t.string "medication_name", null: false
    t.string "dosage", null: false
    t.string "frequency", null: false
    t.string "duration"
    t.string "route", default: "oral"
    t.integer "quantity"
    t.text "instructions"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["prescription_id"], name: "index_prescription_items_on_prescription_id"
  end

  create_table "prescriptions", force: :cascade do |t|
    t.bigint "visit_id"
    t.bigint "patient_id", null: false
    t.bigint "prescribed_by_id", null: false
    t.integer "status", default: 0, null: false
    t.text "notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["patient_id", "created_at"], name: "index_prescriptions_on_patient_id_and_created_at"
    t.index ["patient_id"], name: "index_prescriptions_on_patient_id"
    t.index ["prescribed_by_id"], name: "index_prescriptions_on_prescribed_by_id"
    t.index ["status"], name: "index_prescriptions_on_status"
    t.index ["visit_id"], name: "index_prescriptions_on_visit_id"
  end

  create_table "recurring_schedules", force: :cascade do |t|
    t.bigint "patient_id", null: false
    t.bigint "doctor_id", null: false
    t.bigint "service_id", null: false
    t.integer "days_of_week", default: [], array: true
    t.time "start_time", null: false
    t.date "start_date", null: false
    t.date "end_date"
    t.boolean "active", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["days_of_week"], name: "index_recurring_schedules_on_days_of_week", using: :gin
    t.index ["doctor_id"], name: "index_recurring_schedules_on_doctor_id"
    t.index ["patient_id"], name: "index_recurring_schedules_on_patient_id"
    t.index ["service_id"], name: "index_recurring_schedules_on_service_id"
  end

  create_table "schedule_exceptions", force: :cascade do |t|
    t.bigint "doctor_id", null: false
    t.date "exception_date", null: false
    t.boolean "available", default: false, null: false
    t.time "start_time"
    t.time "end_time"
    t.string "reason"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["doctor_id", "exception_date"], name: "index_schedule_exceptions_on_doctor_id_and_exception_date", unique: true
    t.index ["doctor_id"], name: "index_schedule_exceptions_on_doctor_id"
  end

  create_table "services", force: :cascade do |t|
    t.bigint "department_id"
    t.string "name", null: false
    t.text "description"
    t.integer "price_cents", default: 0, null: false
    t.integer "duration_minutes", default: 30
    t.integer "service_type", default: 0
    t.boolean "active", default: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["department_id"], name: "index_services_on_department_id"
  end

  create_table "staff_profiles", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "department_id"
    t.string "employee_id"
    t.string "specialization"
    t.string "license_number"
    t.string "qualification"
    t.text "bio"
    t.integer "consultation_fee_cents", default: 0
    t.boolean "available_for_telemedicine", default: false
    t.integer "years_of_experience"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["department_id"], name: "index_staff_profiles_on_department_id"
    t.index ["employee_id"], name: "index_staff_profiles_on_employee_id", unique: true
    t.index ["user_id"], name: "index_staff_profiles_on_user_id", unique: true
  end

  create_table "telemedicine_sessions", force: :cascade do |t|
    t.bigint "appointment_id"
    t.bigint "patient_id", null: false
    t.bigint "doctor_id", null: false
    t.string "room_id", null: false
    t.integer "status", default: 0, null: false
    t.datetime "started_at"
    t.datetime "ended_at"
    t.text "notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["appointment_id"], name: "index_telemedicine_sessions_on_appointment_id"
    t.index ["doctor_id"], name: "index_telemedicine_sessions_on_doctor_id"
    t.index ["patient_id", "created_at"], name: "index_telemedicine_sessions_on_patient_id_and_created_at"
    t.index ["patient_id"], name: "index_telemedicine_sessions_on_patient_id"
    t.index ["room_id"], name: "index_telemedicine_sessions_on_room_id", unique: true
    t.index ["status"], name: "index_telemedicine_sessions_on_status"
  end

  create_table "testimonials", force: :cascade do |t|
    t.string "patient_name", null: false
    t.text "content", null: false
    t.integer "rating"
    t.boolean "approved", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "transplant_waitlist_entries", force: :cascade do |t|
    t.bigint "patient_id", null: false
    t.date "listed_date", null: false
    t.string "blood_group", null: false
    t.integer "status", default: 0, null: false
    t.integer "priority", default: 0, null: false
    t.integer "pra_level"
    t.text "notes"
    t.date "transplant_date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["patient_id"], name: "index_transplant_waitlist_entries_on_patient_id"
    t.index ["status", "priority", "listed_date"], name: "idx_waitlist_priority"
    t.index ["status"], name: "index_transplant_waitlist_entries_on_status"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "first_name", null: false
    t.string "last_name", null: false
    t.string "phone"
    t.integer "role", default: 0, null: false
    t.boolean "active", default: true
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.string "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string "unconfirmed_email"
    t.integer "failed_attempts", default: 0, null: false
    t.string "unlock_token"
    t.datetime "locked_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["phone"], name: "index_users_on_phone"
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["role"], name: "index_users_on_role"
    t.index ["unlock_token"], name: "index_users_on_unlock_token", unique: true
  end

  create_table "vascular_accesses", force: :cascade do |t|
    t.bigint "patient_id", null: false
    t.integer "access_type", default: 0, null: false
    t.string "location"
    t.date "created_on"
    t.integer "status", default: 0, null: false
    t.date "last_assessed_on"
    t.text "notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["patient_id"], name: "index_vascular_accesses_on_patient_id"
  end

  create_table "visits", force: :cascade do |t|
    t.bigint "appointment_id"
    t.bigint "patient_id", null: false
    t.bigint "doctor_id", null: false
    t.date "visit_date", null: false
    t.integer "visit_type", default: 0, null: false
    t.text "chief_complaint"
    t.integer "status", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["appointment_id"], name: "index_visits_on_appointment_id"
    t.index ["doctor_id"], name: "index_visits_on_doctor_id"
    t.index ["patient_id", "visit_date"], name: "index_visits_on_patient_id_and_visit_date"
    t.index ["patient_id"], name: "index_visits_on_patient_id"
    t.index ["status"], name: "index_visits_on_status"
  end

  create_table "vital_signs", force: :cascade do |t|
    t.bigint "visit_id"
    t.bigint "patient_id", null: false
    t.bigint "recorded_by_id", null: false
    t.integer "measurement_type", default: 0, null: false
    t.integer "systolic_bp"
    t.integer "diastolic_bp"
    t.integer "heart_rate"
    t.decimal "temperature", precision: 4, scale: 1
    t.decimal "weight_kg", precision: 5, scale: 1
    t.decimal "height_cm", precision: 5, scale: 1
    t.integer "respiratory_rate"
    t.integer "oxygen_saturation"
    t.decimal "blood_sugar", precision: 5, scale: 1
    t.datetime "recorded_at", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["measurement_type"], name: "index_vital_signs_on_measurement_type"
    t.index ["patient_id", "recorded_at"], name: "index_vital_signs_on_patient_id_and_recorded_at"
    t.index ["patient_id"], name: "index_vital_signs_on_patient_id"
    t.index ["recorded_by_id"], name: "index_vital_signs_on_recorded_by_id"
    t.index ["visit_id"], name: "index_vital_signs_on_visit_id"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "allergies", "users", column: "patient_id"
  add_foreign_key "appointments", "departments"
  add_foreign_key "appointments", "recurring_schedules"
  add_foreign_key "appointments", "services"
  add_foreign_key "appointments", "users", column: "checked_in_by_id"
  add_foreign_key "appointments", "users", column: "doctor_id"
  add_foreign_key "appointments", "users", column: "patient_id"
  add_foreign_key "blog_posts", "users", column: "author_id"
  add_foreign_key "clinical_notes", "users", column: "author_id"
  add_foreign_key "clinical_notes", "visits"
  add_foreign_key "contact_submissions", "users", column: "assigned_to_id"
  add_foreign_key "contact_submissions", "users", column: "responded_by_id"
  add_foreign_key "conversation_participants", "conversations"
  add_foreign_key "conversation_participants", "users"
  add_foreign_key "conversations", "users", column: "patient_id"
  add_foreign_key "departments", "users", column: "head_of_department_id"
  add_foreign_key "diagnoses", "users", column: "diagnosed_by_id"
  add_foreign_key "diagnoses", "users", column: "patient_id"
  add_foreign_key "diagnoses", "visits"
  add_foreign_key "dialysis_consumable_usages", "dialysis_consumables"
  add_foreign_key "dialysis_consumable_usages", "dialysis_sessions"
  add_foreign_key "dialysis_sessions", "appointments"
  add_foreign_key "dialysis_sessions", "dialysis_machines"
  add_foreign_key "dialysis_sessions", "dialysis_stations"
  add_foreign_key "dialysis_sessions", "users", column: "doctor_id"
  add_foreign_key "dialysis_sessions", "users", column: "nurse_id"
  add_foreign_key "dialysis_sessions", "users", column: "patient_id"
  add_foreign_key "diet_logs", "users", column: "patient_id"
  add_foreign_key "doctor_schedules", "users", column: "doctor_id"
  add_foreign_key "emergency_contacts", "users", column: "patient_id"
  add_foreign_key "home_readings", "users", column: "patient_id"
  add_foreign_key "insurance_claims", "invoices"
  add_foreign_key "insurance_claims", "users", column: "patient_id"
  add_foreign_key "invoice_items", "invoices"
  add_foreign_key "invoice_items", "services"
  add_foreign_key "invoices", "users", column: "patient_id"
  add_foreign_key "invoices", "visits"
  add_foreign_key "lab_orders", "users", column: "ordered_by_id"
  add_foreign_key "lab_orders", "users", column: "patient_id"
  add_foreign_key "lab_orders", "visits"
  add_foreign_key "lab_results", "lab_orders"
  add_foreign_key "lab_results", "lab_tests"
  add_foreign_key "lab_results", "users", column: "patient_id"
  add_foreign_key "lab_results", "users", column: "resulted_by_id"
  add_foreign_key "lead_activities", "contact_submissions"
  add_foreign_key "lead_activities", "users"
  add_foreign_key "medications", "users", column: "patient_id"
  add_foreign_key "medications", "users", column: "prescribed_by_id"
  add_foreign_key "messages", "conversations"
  add_foreign_key "messages", "users", column: "sender_id"
  add_foreign_key "notification_preferences", "users"
  add_foreign_key "notifications", "users", column: "actor_id"
  add_foreign_key "notifications", "users", column: "recipient_id"
  add_foreign_key "pages", "users", column: "author_id"
  add_foreign_key "patient_profiles", "users"
  add_foreign_key "patient_surveys", "users", column: "patient_id"
  add_foreign_key "patient_surveys", "visits"
  add_foreign_key "payments", "invoices"
  add_foreign_key "payments", "users", column: "patient_id"
  add_foreign_key "prescription_items", "prescriptions"
  add_foreign_key "prescriptions", "users", column: "patient_id"
  add_foreign_key "prescriptions", "users", column: "prescribed_by_id"
  add_foreign_key "prescriptions", "visits"
  add_foreign_key "recurring_schedules", "services"
  add_foreign_key "recurring_schedules", "users", column: "doctor_id"
  add_foreign_key "recurring_schedules", "users", column: "patient_id"
  add_foreign_key "schedule_exceptions", "users", column: "doctor_id"
  add_foreign_key "services", "departments"
  add_foreign_key "staff_profiles", "departments"
  add_foreign_key "staff_profiles", "users"
  add_foreign_key "telemedicine_sessions", "appointments"
  add_foreign_key "telemedicine_sessions", "users", column: "doctor_id"
  add_foreign_key "telemedicine_sessions", "users", column: "patient_id"
  add_foreign_key "transplant_waitlist_entries", "users", column: "patient_id"
  add_foreign_key "vascular_accesses", "users", column: "patient_id"
  add_foreign_key "visits", "appointments"
  add_foreign_key "visits", "users", column: "doctor_id"
  add_foreign_key "visits", "users", column: "patient_id"
  add_foreign_key "vital_signs", "users", column: "patient_id"
  add_foreign_key "vital_signs", "users", column: "recorded_by_id"
  add_foreign_key "vital_signs", "visits"
end
