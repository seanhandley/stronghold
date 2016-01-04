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

ActiveRecord::Schema.define(version: 20161215102724) do

  create_table "audits", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.string   "auditable_id"
    t.string   "auditable_type"
    t.integer  "associated_id"
    t.string   "associated_type"
    t.integer  "user_id"
    t.string   "user_type"
    t.string   "username"
    t.string   "action"
    t.text     "audited_changes", limit: 65535
    t.integer  "version",                       default: 0
    t.string   "comment"
    t.string   "remote_address"
    t.datetime "created_at"
    t.integer  "organization_id"
    t.string   "request_uuid"
    t.index ["associated_id", "associated_type"], name: "associated_index", using: :btree
    t.index ["auditable_id", "auditable_type"], name: "auditable_index", using: :btree
    t.index ["created_at"], name: "index_audits_on_created_at", using: :btree
    t.index ["organization_id"], name: "index_audits_on_organization_id", using: :btree
    t.index ["request_uuid"], name: "index_audits_on_request_uuid", using: :btree
    t.index ["user_id", "user_type"], name: "user_index", using: :btree
  end

  create_table "billing_image_states", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.datetime "recorded_at",            precision: 3
    t.string   "event_name"
    t.float    "size",        limit: 24
    t.integer  "image_id"
    t.integer  "sync_id"
    t.string   "message_id"
    t.index ["image_id"], name: "image_states", using: :btree
    t.index ["recorded_at"], name: "index_billing_image_states_on_recorded_at", using: :btree
    t.index ["sync_id"], name: "image_syncs", using: :btree
  end

  create_table "billing_images", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.string "image_id"
    t.string "name"
    t.string "project_id"
    t.index ["image_id"], name: "index_billing_images_on_image_id", unique: true, using: :btree
    t.index ["project_id"], name: "tenant_images", using: :btree
  end

  create_table "billing_instance_flavors", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.string  "flavor_id"
    t.string  "name"
    t.integer "ram"
    t.integer "disk"
    t.integer "vcpus"
    t.float   "rate",      limit: 24
  end

  create_table "billing_instance_states", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.integer  "instance_id"
    t.datetime "recorded_at",       precision: 3
    t.string   "state"
    t.string   "message_id"
    t.string   "event_name"
    t.integer  "sync_id"
    t.string   "flavor_id"
    t.integer  "previous_state_id"
    t.integer  "next_state_id"
    t.index ["instance_id"], name: "instance_states", using: :btree
    t.index ["next_state_id"], name: "index_billing_instance_states_on_next_state_id", using: :btree
    t.index ["previous_state_id"], name: "index_billing_instance_states_on_previous_state_id", using: :btree
    t.index ["recorded_at"], name: "index_billing_instance_states_on_recorded_at", using: :btree
    t.index ["sync_id"], name: "instance_syncs", using: :btree
  end

  create_table "billing_instances", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.string   "instance_id"
    t.string   "name"
    t.string   "flavor_id"
    t.string   "image_id"
    t.string   "project_id"
    t.string   "arch",                        default: "x86_64", null: false
    t.datetime "terminated_at"
    t.integer  "billable_seconds"
    t.float    "cost",             limit: 24
    t.datetime "started_at"
    t.index ["flavor_id"], name: "instance_flavors", using: :btree
    t.index ["instance_id"], name: "index_billing_instances_on_instance_id", unique: true, using: :btree
    t.index ["project_id"], name: "tenant_instances", using: :btree
    t.index ["terminated_at"], name: "index_billing_instances_on_terminated_at", using: :btree
  end

  create_table "billing_invoices", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.integer  "organization_id",                              null: false
    t.integer  "year",                                         null: false
    t.integer  "month",                                        null: false
    t.float    "sub_total",         limit: 24, default: 0.0,   null: false
    t.float    "grand_total",       limit: 24, default: 0.0,   null: false
    t.integer  "discount_percent",             default: 0,     null: false
    t.integer  "tax_percent",                  default: 20,    null: false
    t.string   "stripe_invoice_id"
    t.string   "salesforce_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "finalized",                    default: false, null: false
  end

  create_table "billing_ip_quotas", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.string   "project_id"
    t.integer  "quota"
    t.datetime "recorded_at", precision: 3
    t.integer  "sync_id"
    t.integer  "previous"
    t.index ["project_id"], name: "tenant_ip_quotas", using: :btree
    t.index ["recorded_at"], name: "index_billing_ip_quotas_on_recorded_at", using: :btree
  end

  create_table "billing_ips", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.string   "ip_id"
    t.string   "address"
    t.string   "project_id"
    t.datetime "recorded_at", precision: 3
    t.string   "message_id"
    t.string   "ip_type"
    t.integer  "sync_id"
    t.index ["project_id"], name: "tenant_ips", using: :btree
    t.index ["recorded_at"], name: "index_billing_ips_on_recorded_at", using: :btree
  end

  create_table "billing_line_items", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.string   "product_id"
    t.integer  "invoice_id"
    t.float    "quantity",      limit: 24
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "salesforce_id"
    t.string   "description"
  end

  create_table "billing_load_balancers", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.string   "lb_id"
    t.string   "name"
    t.string   "project_id"
    t.datetime "started_at"
    t.datetime "terminated_at"
    t.integer  "sync_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "billing_storage_objects", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.string   "project_id"
    t.bigint   "size"
    t.datetime "recorded_at", precision: 3
    t.integer  "sync_id"
    t.index ["project_id"], name: "index_billing_storage_objects_on_project_id", using: :btree
    t.index ["project_id"], name: "tenant_storage_objects", using: :btree
    t.index ["recorded_at"], name: "index_billing_storage_objects_on_recorded_at", using: :btree
  end

  create_table "billing_syncs", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.datetime "completed_at", precision: 3
    t.datetime "started_at",   precision: 3
    t.datetime "period_from",  precision: 3
    t.datetime "period_to",    precision: 3
  end

  create_table "billing_usages", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.integer  "year"
    t.integer  "month"
    t.integer  "organization_id"
    t.string   "object_uuid"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "billing_volume_states", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.datetime "recorded_at", precision: 3
    t.string   "event_name"
    t.integer  "size"
    t.integer  "volume_id"
    t.string   "message_id"
    t.integer  "sync_id"
    t.string   "volume_type"
    t.index ["recorded_at"], name: "index_billing_volume_states_on_recorded_at", using: :btree
    t.index ["sync_id"], name: "volume_syncs", using: :btree
    t.index ["volume_id"], name: "volume_states", using: :btree
  end

  create_table "billing_volumes", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.string   "volume_id"
    t.string   "name"
    t.string   "project_id"
    t.datetime "deleted_at"
    t.index ["deleted_at"], name: "index_billing_volumes_on_deleted_at", using: :btree
    t.index ["project_id"], name: "tenant_volumes", using: :btree
    t.index ["volume_id"], name: "index_billing_volumes_on_volume_id", unique: true, using: :btree
  end

  create_table "billing_vpn_connections", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.string   "vpn_connection_id"
    t.string   "name"
    t.string   "project_id"
    t.datetime "started_at"
    t.datetime "terminated_at"
    t.integer  "sync_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "customer_signups", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.string   "uuid"
    t.string   "email"
    t.string   "organization_name"
    t.string   "stripe_customer_id"
    t.string   "ip_address"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "reminder_sent",       default: false, null: false
    t.string   "discount_code"
    t.string   "real_ip"
    t.string   "forwarded_ip"
    t.string   "device_id"
    t.integer  "activation_attempts", default: 0,     null: false
    t.string   "user_agent"
    t.string   "accept_language"
    t.boolean  "retro_migrated"
  end

  create_table "invites", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.string   "email"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "completed_at"
    t.string   "token"
    t.integer  "organization_id"
    t.boolean  "power_invite",       default: false, null: false
    t.integer  "customer_signup_id"
    t.string   "remote_message_id"
  end

  create_table "invites_projects", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.integer  "invite_id"
    t.integer  "project_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "invites_roles", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.integer  "role_id"
    t.integer  "invite_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "organization_transitions", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.string   "to_state",                      null: false
    t.text     "metadata",        limit: 65535
    t.integer  "sort_key",                      null: false
    t.integer  "organization_id",               null: false
    t.boolean  "most_recent"
    t.datetime "created_at",                    null: false
    t.datetime "updated_at",                    null: false
    t.index ["organization_id", "most_recent"], name: "index_organization_transitions_parent_most_recent", unique: true, using: :btree
    t.index ["organization_id", "sort_key"], name: "index_organization_transitions_parent_sort", unique: true, using: :btree
  end

  create_table "organization_vouchers", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.integer  "organization_id"
    t.integer  "voucher_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["organization_id", "voucher_id"], name: "index_organization_vouchers_on_organization_id_and_voucher_id", unique: true, using: :btree
  end

  create_table "organizations", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.string   "reference"
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "time_zone",                        default: "London", null: false
    t.string   "locale",                           default: "en",     null: false
    t.integer  "primary_project_id"
    t.datetime "started_paying_at"
    t.string   "stripe_customer_id"
    t.boolean  "self_service",                     default: true,     null: false
    t.string   "salesforce_id"
    t.string   "billing_address1"
    t.string   "billing_address2"
    t.string   "billing_city"
    t.string   "billing_postcode"
    t.string   "billing_country"
    t.string   "phone"
    t.integer  "customer_signup_id"
    t.string   "state",                            default: "active", null: false
    t.boolean  "disabled",                         default: false,    null: false
    t.boolean  "test_account",                     default: false,    null: false
    t.string   "reporting_code"
    t.boolean  "limited_storage",                  default: false,    null: false
    t.integer  "projects_limit",                   default: 1,        null: false
    t.float    "weekly_spend",       limit: 24,    default: 0.0,      null: false
    t.text     "quota_limit",        limit: 65535
    t.string   "billing_contact"
    t.boolean  "bill_automatically",               default: true,     null: false
    t.string   "technical_contact"
    t.index ["reporting_code"], name: "index_organizations_on_reporting_code", unique: true, using: :btree
    t.index ["state"], name: "index_organizations_on_state", using: :btree
  end

  create_table "organizations_products", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.integer  "organization_id"
    t.integer  "product_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "products", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "projects", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.string   "name"
    t.string   "uuid"
    t.integer  "organization_id"
    t.text     "quota_set",       limit: 65535
    t.datetime "deleted_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["deleted_at"], name: "index_projects_on_deleted_at", using: :btree
    t.index ["organization_id"], name: "index_projects_on_organization_id", using: :btree
  end

  create_table "resets", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.string   "email"
    t.string   "token"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "completed_at"
  end

  create_table "roles", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.string   "name"
    t.text     "permissions",     limit: 65535
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "power_user",                    default: false
    t.integer  "organization_id"
  end

  create_table "roles_users", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.integer  "role_id"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "starburst_announcement_views", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.integer  "user_id"
    t.integer  "announcement_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["user_id", "announcement_id"], name: "starburst_announcement_view_index", unique: true, using: :btree
  end

  create_table "starburst_announcements", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.text     "title",               limit: 65535
    t.text     "body",                limit: 65535
    t.datetime "start_delivering_at"
    t.datetime "stop_delivering_at"
    t.text     "limit_to_users",      limit: 65535
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "category",            limit: 65535
  end

  create_table "user_project_roles", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.integer "user_id"
    t.integer "project_id"
    t.string  "role_uuid"
    t.index ["user_id", "project_id", "role_uuid"], name: "index_user_project_roles_on_user_id_and_project_id_and_role_uuid", unique: true, using: :btree
  end

  create_table "users", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.string   "email"
    t.string   "first_name"
    t.string   "last_name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "organization_id"
    t.string   "uuid"
    t.string   "password_digest"
    t.string   "salesforce_id"
    t.datetime "last_seen_online"
  end

  create_table "vouchers", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.string   "name",                                                     null: false
    t.string   "description",                                              null: false
    t.string   "code",                                                     null: false
    t.integer  "duration",         limit: 1,               default: 1,     null: false
    t.decimal  "discount_percent",           precision: 3, default: 10,    null: false
    t.datetime "expires_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "usage_limit"
    t.boolean  "restricted",                               default: false, null: false
    t.index ["code"], name: "index_vouchers_on_code", unique: true, using: :btree
  end

  create_table "wait_list_entries", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.string   "email"
    t.datetime "emailed_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
