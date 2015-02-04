# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20140611155757) do

  create_table "authorizations", force: true do |t|
    t.integer  "permission_label_id"
    t.integer  "title_provider_group_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "authorizations", ["permission_label_id", "title_provider_group_id"], name: "index_unique_provider_group_authorization", unique: true, using: :btree

  create_table "authorized_countries", force: true do |t|
    t.integer  "provider_id"
    t.integer  "country_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "communication_in_jobs", force: true do |t|
    t.string   "job_source"
    t.integer  "job_source_job_id"
    t.string   "type"
    t.text     "params"
    t.integer  "done"
    t.string   "result"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "communication_out_jobs", force: true do |t|
    t.string   "type"
    t.text     "params"
    t.integer  "done"
    t.string   "result"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "countries", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "delayed_jobs", force: true do |t|
    t.integer  "priority",   default: 0
    t.integer  "attempts",   default: 0
    t.text     "handler"
    t.text     "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "queue"
  end

  create_table "images", force: true do |t|
    t.string   "title",                  limit: 192
    t.string   "subject_code",           limit: 708
    t.text     "subject"
    t.string   "instructions",           limit: 768
    t.string   "creator",                limit: 96
    t.string   "city",                   limit: 96
    t.string   "location",               limit: 96
    t.string   "state",                  limit: 96
    t.string   "country",                limit: 192
    t.string   "headline",               limit: 768
    t.string   "credit",                 limit: 96
    t.string   "source",                 limit: 96
    t.text     "description"
    t.string   "reportage",              limit: 96
    t.string   "normalized_credit",      limit: 192
    t.integer  "max_avail_width"
    t.integer  "max_avail_height"
    t.string   "original_filename"
    t.text     "provider_comment"
    t.datetime "date_created"
    t.datetime "reception_date"
    t.string   "thumb_location"
    t.string   "medium_location"
    t.string   "hires_location",         limit: 1000
    t.string   "restrictions",           limit: 512,  default: "ANY"
    t.integer  "provider_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "rights",                 limit: 384
    t.string   "category",               limit: 9
    t.string   "supplemental_category",  limit: 96
    t.integer  "urgency",                limit: 3
    t.string   "authors_position",       limit: 96
    t.string   "transmission_reference", limit: 96
    t.string   "caption_writer",         limit: 96
    t.boolean  "delta",                               default: true,  null: false
    t.float    "ratio"
    t.boolean  "erasable",                            default: false
    t.string   "ms_picture_id"
    t.string   "ms_id"
    t.boolean  "private_image",                       default: false
    t.string   "file_name"
    t.boolean  "content_error",                       default: false, null: false
    t.integer  "ms_image_id",                         default: 0
    t.string   "page_ref",               limit: 150
    t.integer  "hr_size",                             default: 0
    t.integer  "fonds",                               default: 0
  end

  add_index "images", ["created_at"], name: "index_images_on_created_at", using: :btree
  add_index "images", ["date_created"], name: "index_images_on_date_created", using: :btree
  add_index "images", ["delta"], name: "index_images_on_delta", using: :btree
  add_index "images", ["file_name"], name: "index_images_on_file_name", using: :btree
  add_index "images", ["original_filename", "provider_id"], name: "index_images_on_original_filename_and_provider_id", unique: true, using: :btree
  add_index "images", ["private_image"], name: "index_images_on_private_image", using: :btree
  add_index "images", ["provider_id"], name: "index_images_on_provider_id", using: :btree
  add_index "images", ["ratio"], name: "index_images_on_ratio", using: :btree
  add_index "images", ["reception_date"], name: "index_images_on_reception_date", using: :btree
  add_index "images", ["reportage"], name: "index_images_on_reportage", using: :btree
  add_index "images", ["updated_at"], name: "index_images_on_updated_at", using: :btree

  create_table "light_box_images", force: true do |t|
    t.string   "annotation"
    t.integer  "light_box_id"
    t.integer  "image_id"
    t.integer  "position"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "light_box_images", ["image_id"], name: "index_light_box_images_on_image_id", using: :btree
  add_index "light_box_images", ["light_box_id"], name: "index_light_box_images_on_light_box_id", using: :btree

  create_table "light_boxes", force: true do |t|
    t.boolean  "order_by_agency",           default: false
    t.string   "name"
    t.integer  "user_id"
    t.integer  "title_id"
    t.string   "hash_code"
    t.integer  "items_count",               default: 0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "permission",      limit: 1, default: 0
  end

  add_index "light_boxes", ["name"], name: "index_light_boxes_on_name", using: :btree
  add_index "light_boxes", ["user_id"], name: "index_light_boxes_on_user_id", using: :btree

  create_table "metadata_conversions", force: true do |t|
    t.string "image"
    t.string "iptc"
    t.string "eightbim"
    t.string "xmp"
  end

  create_table "net_messages", force: true do |t|
    t.text     "message",                     null: false
    t.text     "answer"
    t.datetime "answered_at"
    t.boolean  "skipable",    default: false, null: false
    t.integer  "server_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "operation_labels", force: true do |t|
    t.string   "label"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "paniers", force: true do |t|
    t.integer "reportage_id", null: false
    t.integer "user_id",      null: false
  end

  add_index "paniers", ["reportage_id"], name: "index_paniers_on_reportage_id", using: :btree
  add_index "paniers", ["user_id"], name: "index_paniers_on_user_id", using: :btree

  create_table "permission_labels", force: true do |t|
    t.string   "label"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "photo20mins", force: true do |t|
    t.string   "photo"
    t.integer  "user_id"
    t.string   "description"
    t.string   "credit"
    t.string   "city"
    t.datetime "date_photo"
    t.string   "reportage"
    t.string   "keywords"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "photo20mins", ["user_id"], name: "index_photo20mins_on_user_id", using: :btree

  create_table "provider_contacts", force: true do |t|
    t.boolean  "main"
    t.string   "first_name"
    t.string   "last_name"
    t.string   "email",            limit: 100
    t.string   "fax"
    t.string   "phone"
    t.boolean  "receive_requests"
    t.integer  "provider_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "portable"
    t.boolean  "receive_stat"
  end

  create_table "provider_for_search_stats", force: true do |t|
    t.integer "search_stat_id", default: 0
    t.text    "provs"
  end

  add_index "provider_for_search_stats", ["search_stat_id"], name: "index_provider_for_search_stats_on_search_stat_id", using: :btree

  create_table "provider_response_to_requests", force: true do |t|
    t.integer  "request_to_provider_id"
    t.integer  "image_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "provider_response_to_requests", ["request_to_provider_id"], name: "index_provider_response_to_requests_on_request_to_provider_id", using: :btree

  create_table "providers", force: true do |t|
    t.string   "name"
    t.string   "logo"
    t.string   "description",           limit: 750
    t.string   "site"
    t.string   "address"
    t.boolean  "local",                             default: false
    t.string   "copyright_rule"
    t.string   "string_key"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "days_keep"
    t.boolean  "days_keep_per_picture",             default: false
    t.boolean  "form_per_session",                  default: false
    t.string   "provider_conditions"
    t.string   "input_dir"
    t.string   "city"
    t.string   "country"
    t.string   "zip_code"
    t.string   "text_prices_url"
    t.boolean  "actif",                             default: true
    t.integer  "toomany_limit",                     default: 0
    t.string   "pdf"
    t.string   "formu"
    t.string   "name_order"
  end

  create_table "reportage_photos", force: true do |t|
    t.integer "reportage_id"
    t.integer "photo_ms_id"
    t.integer "rang",         default: 0
  end

  add_index "reportage_photos", ["photo_ms_id"], name: "index_reportage_photos_on_photo_ms_id", using: :btree
  add_index "reportage_photos", ["reportage_id"], name: "index_reportage_photos_on_reportage_id", using: :btree

  create_table "reportages", force: true do |t|
    t.string   "no_reportage", limit: 96
    t.string   "string_key",   limit: 70
    t.integer  "nb_photos",                default: 0
    t.integer  "prem_photo",                           null: false
    t.string   "rep_titre",    limit: 192
    t.text     "rep_texte"
    t.date     "rep_date"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "signatur",     limit: 96
    t.boolean  "offre"
  end

  add_index "reportages", ["no_reportage"], name: "index_reportages_on_no_reportage", using: :btree
  add_index "reportages", ["rep_date"], name: "index_reportages_on_rep_date", using: :btree
  add_index "reportages", ["rep_titre"], name: "index_reportages_on_rep_titre", using: :btree
  add_index "reportages", ["string_key"], name: "index_reportages_on_string_key", using: :btree

  create_table "request_to_providers", force: true do |t|
    t.string   "text"
    t.date     "view_date"
    t.string   "status"
    t.string   "subject"
    t.integer  "responses_count", default: 0
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "serial"
  end

  add_index "request_to_providers", ["user_id"], name: "index_request_to_providers_on_user_id", using: :btree

  create_table "roles", force: true do |t|
    t.string   "name"
    t.text     "permissions"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "saved_searches", force: true do |t|
    t.integer  "user_id"
    t.string   "name"
    t.datetime "date"
    t.datetime "date_last_search"
    t.integer  "photos_count"
    t.text     "criteria"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "search_image_fields", force: true do |t|
    t.integer "search_stat_id", default: 0
    t.text    "iptc"
  end

  add_index "search_image_fields", ["search_stat_id"], name: "index_search_image_fields_on_search_stat_id", using: :btree

  create_table "search_provider_group_names", force: true do |t|
    t.string   "name",       null: false
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "search_provider_group_names", ["name", "user_id"], name: "index_search_provider_group_names_on_name_and_user_id", unique: true, using: :btree

  create_table "search_provider_groups", force: true do |t|
    t.integer  "provider_id"
    t.integer  "search_provider_group_name_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "search_stats", force: true do |t|
    t.string   "keyword"
    t.string   "since",           limit: 50
    t.string   "tri",             limit: 50
    t.date     "date_pp_from"
    t.date     "date_pp_to"
    t.date     "date_photo_from"
    t.date     "date_photo_to"
    t.integer  "format"
    t.integer  "result",                     default: 0
    t.integer  "user_id"
    t.datetime "created_at"
  end

  add_index "search_stats", ["result"], name: "index_search_stats_on_result", using: :btree
  add_index "search_stats", ["user_id"], name: "index_search_stats_on_user_id", using: :btree

  create_table "selected_providers_for_requests", force: true do |t|
    t.integer  "request_to_provider_id"
    t.integer  "provider_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "servers", force: true do |t|
    t.string   "status"
    t.string   "host"
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "which_type"
    t.boolean  "is_self",    default: false,  null: false
    t.string   "api_key"
    t.string   "api_port",   default: "5671", null: false
  end

  create_table "sessions", force: true do |t|
    t.string   "session_id", null: false
    t.text     "data"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "sessions", ["session_id"], name: "index_sessions_on_session_id", using: :btree
  add_index "sessions", ["updated_at"], name: "index_sessions_on_updated_at", using: :btree

  create_table "settings", force: true do |t|
    t.string   "language"
    t.text     "preferential_corpus"
    t.text     "display_params"
    t.text     "border_color_provider"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "time_zone"
    t.integer  "default_per_page",      default: 0,                null: false
    t.string   "default_since",         default: "all",            null: false
    t.string   "default_sort",          default: "reception_date", null: false
    t.integer  "reload_pref",           default: 0
  end

  add_index "settings", ["user_id"], name: "index_settings_on_user_id", using: :btree

  create_table "statistics", force: true do |t|
    t.integer  "user_id"
    t.integer  "image_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "delta",              default: true
    t.integer  "operation_label_id"
    t.string   "id20min"
  end

  add_index "statistics", ["image_id"], name: "index_statistics_on_image_id", using: :btree
  add_index "statistics", ["user_id"], name: "index_statistics_on_user_id", using: :btree

  create_table "title_provider_group_names", force: true do |t|
    t.string   "name"
    t.integer  "country_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "title_provider_group_names", ["name", "country_id"], name: "index_title_provider_group_names_on_name_and_country_id", unique: true, using: :btree

  create_table "title_provider_groups", force: true do |t|
    t.integer  "title_provider_group_name_id"
    t.integer  "provider_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "titles", force: true do |t|
    t.string   "name"
    t.boolean  "hide_unauthorized_providers",              default: true
    t.integer  "dpi",                                      default: 75
    t.string   "flow_path"
    t.integer  "title_provider_group_name_id"
    t.integer  "server_id"
    t.integer  "country_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "first_name",                   limit: 100, default: ""
    t.string   "last_name",                    limit: 100, default: ""
    t.string   "address",                      limit: 150, default: ""
    t.string   "zip_code",                     limit: 10,  default: ""
    t.string   "city",                         limit: 150, default: ""
    t.string   "phone",                        limit: 20,  default: ""
    t.string   "email",                        limit: 100, default: ""
    t.string   "comment",                      limit: 500, default: ""
    t.integer  "visible",                                  default: 0
    t.string   "group",                        limit: 100, default: ""
    t.string   "title_type",                   limit: 100, default: ""
    t.string   "visible_name",                 limit: 100, default: ""
    t.string   "ojd_link",                     limit: 150, default: ""
  end

  create_table "users", force: true do |t|
    t.string   "login",                     limit: 40
    t.string   "first_name",                limit: 100, default: ""
    t.string   "last_name",                 limit: 100, default: ""
    t.string   "email",                     limit: 100
    t.string   "crypted_password",          limit: 128, default: "",  null: false
    t.string   "salt",                      limit: 128, default: "",  null: false
    t.datetime "remember_token_expires_at"
    t.datetime "activated_at"
    t.string   "phone",                                 default: "0"
    t.integer  "fax",                                   default: 0
    t.integer  "numero_tva",                            default: 0
    t.string   "company",                   limit: 40
    t.string   "job",                       limit: 40
    t.string   "activity_sector",           limit: 60
    t.string   "service",                   limit: 40
    t.string   "billing_address"
    t.string   "billing_company"
    t.string   "city"
    t.string   "password_reset_code"
    t.integer  "zip_code"
    t.text     "permissions"
    t.integer  "title_id"
    t.integer  "role_id"
    t.integer  "country_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "login_key"
    t.string   "persistence_token",                                   null: false
    t.string   "perishable_token",                                    null: false
    t.integer  "login_count"
    t.integer  "failed_login_count"
    t.datetime "last_request_at"
    t.datetime "current_login_at"
    t.datetime "last_login_at"
    t.string   "current_login_ip"
    t.string   "last_login_ip"
    t.date     "deactivation_at"
    t.date     "password_updated_at"
    t.integer  "roles_mask",                            default: 4
  end

  add_index "users", ["login"], name: "index_users_on_login", unique: true, using: :btree
  add_index "users", ["login_key"], name: "index_users_on_login_key", unique: true, using: :btree

end
