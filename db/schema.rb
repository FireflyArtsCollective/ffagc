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

ActiveRecord::Schema.define(version: 2021_12_13_155334) do

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.integer "record_id", null: false
    t.integer "blob_id", null: false
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
    t.string "checksum", null: false
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.integer "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "admins", force: :cascade do |t|
    t.string "name"
    t.string "email"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "password_digest"
    t.string "activation_digest"
    t.boolean "activated", default: false
    t.datetime "activated_at"
    t.string "reset_digest"
    t.datetime "reset_sent_at"
  end

  create_table "artist_surveys", force: :cascade do |t|
    t.boolean "has_attended_firefly"
    t.string "has_attended_firefly_desc"
    t.boolean "has_attended_regional"
    t.string "has_attended_regional_desc"
    t.boolean "has_attended_bm"
    t.string "has_attended_bm_desc"
    t.boolean "can_use_as_example"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "artist_id"
    t.index ["artist_id"], name: "index_artist_surveys_on_artist_id"
  end

  create_table "artists", force: :cascade do |t|
    t.string "name"
    t.string "email"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "password_digest"
    t.string "contact_name"
    t.string "contact_phone"
    t.string "contact_street"
    t.string "contact_city"
    t.string "contact_state"
    t.string "contact_country"
    t.string "activation_digest"
    t.boolean "activated", default: false
    t.datetime "activated_at"
    t.string "reset_digest"
    t.datetime "reset_sent_at"
    t.string "contact_zipcode"
  end

  create_table "grant_submissions", force: :cascade do |t|
    t.string "name"
    t.string "description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "grant_id"
    t.integer "artist_id"
    t.string "proposal"
    t.integer "granted_funding_dollars"
    t.boolean "funding_decision"
    t.string "questions"
    t.string "answers"
    t.datetime "questions_updated_at"
    t.datetime "answers_updated_at"
    t.string "private_funding_notes"
    t.string "public_funding_notes"
    t.string "funding_requests_csv"
    t.index ["artist_id"], name: "index_grant_submissions_on_artist_id"
    t.index ["grant_id"], name: "index_grant_submissions_on_grant_id"
  end

  create_table "grants", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "submit_start"
    t.datetime "submit_end"
    t.datetime "vote_start"
    t.datetime "vote_end"
    t.datetime "meeting_one"
    t.datetime "meeting_two"
    t.boolean "hidden", default: false
    t.string "funding_levels_csv"
    t.string "contract_template"
  end

  create_table "grants_voters", force: :cascade do |t|
    t.integer "voter_id"
    t.integer "grant_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "proposals", force: :cascade do |t|
    t.string "file"
    t.integer "grant_submission_id"
    t.index ["grant_submission_id"], name: "index_proposals_on_grant_submission_id"
  end

  create_table "submission_tags", force: :cascade do |t|
    t.integer "tag_id"
    t.integer "grant_submission_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["grant_submission_id"], name: "index_submission_tags_on_grant_submission_id"
    t.index ["tag_id"], name: "index_submission_tags_on_tag_id"
  end

  create_table "tags", force: :cascade do |t|
    t.string "name"
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "hidden", default: false
  end

  create_table "voter_submission_assignments", force: :cascade do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "voter_id"
    t.integer "grant_submission_id"
  end

  create_table "voter_surveys", force: :cascade do |t|
    t.boolean "has_attended_firefly"
    t.boolean "not_applying_this_year"
    t.boolean "will_read"
    t.boolean "will_meet"
    t.boolean "has_been_voter"
    t.boolean "has_participated_other"
    t.boolean "has_received_grant"
    t.boolean "has_received_other_grant"
    t.integer "how_many_fireflies"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "voter_id"
    t.boolean "signed_agreement", default: false
    t.index ["voter_id"], name: "index_voter_surveys_on_voter_id"
  end

  create_table "voters", force: :cascade do |t|
    t.string "name"
    t.string "email"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "password_digest"
    t.boolean "verified"
    t.string "activation_digest"
    t.boolean "activated", default: false
    t.datetime "activated_at"
    t.string "reset_digest"
    t.datetime "reset_sent_at"
  end

  create_table "votes", force: :cascade do |t|
    t.integer "score_t"
    t.integer "score_c"
    t.integer "score_f"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "voter_id"
    t.integer "grant_submission_id"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "submission_tags", "grant_submissions"
  add_foreign_key "submission_tags", "tags"
end
