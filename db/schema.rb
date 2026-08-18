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

ActiveRecord::Schema[8.1].define(version: 2026_07_29_152804) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "active_storage_attachments", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.bigint "record_id", null: false
    t.string "record_type", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.string "content_type"
    t.datetime "created_at", null: false
    t.string "filename", null: false
    t.string "key", null: false
    t.text "metadata"
    t.string "service_name", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "audits1984_audits", force: :cascade do |t|
    t.bigint "auditor_id", null: false
    t.datetime "created_at", null: false
    t.text "notes"
    t.bigint "session_id", null: false
    t.integer "status", default: 0, null: false
    t.datetime "updated_at", null: false
    t.index ["auditor_id"], name: "index_audits1984_audits_on_auditor_id"
    t.index ["session_id"], name: "index_audits1984_audits_on_session_id"
  end

  create_table "bulk_search_logs", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "csv"
    t.bigint "dsi_user_id", null: false
    t.integer "query_count"
    t.integer "result_count"
    t.datetime "updated_at", null: false
    t.index ["dsi_user_id"], name: "index_bulk_search_logs_on_dsi_user_id"
  end

  create_table "bulk_search_responses", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.jsonb "body"
    t.datetime "created_at", null: false
    t.bigint "dsi_user_id", null: false
    t.datetime "expires_at"
    t.integer "total"
    t.datetime "updated_at", null: false
    t.index ["dsi_user_id"], name: "index_bulk_search_responses_on_dsi_user_id"
  end

  create_table "console1984_commands", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "sensitive_access_id"
    t.bigint "session_id", null: false
    t.text "statements"
    t.datetime "updated_at", null: false
    t.index ["sensitive_access_id"], name: "index_console1984_commands_on_sensitive_access_id"
    t.index ["session_id", "created_at", "sensitive_access_id"], name: "on_session_and_sensitive_chronologically"
  end

  create_table "console1984_sensitive_accesses", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "justification"
    t.bigint "session_id", null: false
    t.datetime "updated_at", null: false
    t.index ["session_id"], name: "index_console1984_sensitive_accesses_on_session_id"
  end

  create_table "console1984_sessions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "reason"
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["created_at"], name: "index_console1984_sessions_on_created_at"
    t.index ["user_id", "created_at"], name: "index_console1984_sessions_on_user_id_and_created_at"
  end

  create_table "console1984_users", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "username", null: false
    t.index ["username"], name: "index_console1984_users_on_username"
  end

  create_table "data_migrations", primary_key: "version", id: :string, force: :cascade do |t|
  end

  create_table "date_of_birth_changes", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.date "date_of_birth"
    t.string "malware_scan_result", default: "pending", null: false
    t.string "reference_number"
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["user_id"], name: "index_date_of_birth_changes_on_user_id"
  end

  create_table "dsi_user_sessions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "dsi_user_id"
    t.string "organisation_id"
    t.string "organisation_name"
    t.string "role_code"
    t.string "role_id"
    t.datetime "updated_at", null: false
    t.index ["dsi_user_id"], name: "index_dsi_user_sessions_on_dsi_user_id"
  end

  create_table "dsi_users", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email", limit: 510, null: false
    t.string "first_name", limit: 510
    t.string "last_name", limit: 510
    t.datetime "terms_and_conditions_accepted_at"
    t.string "terms_and_conditions_version_accepted"
    t.string "uid", null: false
    t.datetime "updated_at", null: false
  end

  create_table "feature_flags_features", force: :cascade do |t|
    t.boolean "active", default: false, null: false
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_feature_flags_features_on_name", unique: true
  end

  create_table "feedbacks", force: :cascade do |t|
    t.boolean "contact_permission_given", null: false
    t.datetime "created_at", null: false
    t.string "email"
    t.text "improvement_suggestion", null: false
    t.string "satisfaction_rating", null: false
    t.string "service", null: false
    t.datetime "updated_at", null: false
  end

  create_table "name_changes", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "first_name"
    t.string "last_name"
    t.string "malware_scan_result", default: "pending", null: false
    t.string "middle_name"
    t.string "reference_number"
    t.datetime "updated_at", null: false
    t.bigint "user_id"
    t.index ["user_id"], name: "index_name_changes_on_user_id"
  end

  create_table "roles", force: :cascade do |t|
    t.string "code", null: false
    t.datetime "created_at", null: false
    t.boolean "enabled", default: false, null: false
    t.boolean "internal", default: false, null: false
    t.datetime "updated_at", null: false
    t.index "lower((code)::text)", name: "index_roles_on_lower_code", unique: true
  end

  create_table "search_logs", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.date "date_of_birth"
    t.bigint "dsi_user_id"
    t.string "last_name"
    t.integer "result_count"
    t.string "search_type"
    t.datetime "updated_at", null: false
    t.index ["dsi_user_id"], name: "index_search_logs_on_dsi_user_id"
  end

  create_table "sessions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "data"
    t.string "session_id", null: false
    t.datetime "updated_at", null: false
    t.index ["session_id"], name: "index_sessions_on_session_id", unique: true
    t.index ["updated_at"], name: "index_sessions_on_updated_at"
  end

  create_table "users", force: :cascade do |t|
    t.string "auth_provider"
    t.string "auth_uuid"
    t.datetime "created_at", null: false
    t.date "date_of_birth"
    t.string "email", limit: 510, default: "", null: false
    t.string "family_name", limit: 510
    t.string "given_name", limit: 510
    t.string "name"
    t.date "one_login_verified_birth_date"
    t.string "one_login_verified_name"
    t.string "trn"
    t.datetime "updated_at", null: false
    t.index ["auth_provider", "auth_uuid"], name: "index_users_on_auth_provider_and_auth_uuid", unique: true
    t.index ["email"], name: "index_users_on_email"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "bulk_search_logs", "dsi_users"
  add_foreign_key "bulk_search_responses", "dsi_users"
  add_foreign_key "date_of_birth_changes", "users"
  add_foreign_key "search_logs", "dsi_users"
end
