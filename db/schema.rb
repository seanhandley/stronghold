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

ActiveRecord::Schema.define(version: 20151113090146) do

  create_table "audits", force: :cascade do |t|
    t.string   "auditable_id",    limit: 255
    t.string   "auditable_type",  limit: 255
    t.integer  "associated_id",   limit: 4
    t.string   "associated_type", limit: 255
    t.integer  "user_id",         limit: 4
    t.string   "user_type",       limit: 255
    t.string   "username",        limit: 255
    t.string   "action",          limit: 255
    t.text     "audited_changes", limit: 65535
    t.integer  "version",         limit: 4,     default: 0
    t.string   "comment",         limit: 255
    t.string   "remote_address",  limit: 255
    t.datetime "created_at"
    t.integer  "organization_id", limit: 4
  end

  add_index "audits", ["associated_id", "associated_type"], name: "associated_index", using: :btree
  add_index "audits", ["auditable_id", "auditable_type"], name: "auditable_index", using: :btree
  add_index "audits", ["created_at"], name: "index_audits_on_created_at", using: :btree
  add_index "audits", ["organization_id"], name: "index_audits_on_organization_id", using: :btree
  add_index "audits", ["user_id", "user_type"], name: "user_index", using: :btree

  create_table "billing_external_gateway_states", force: :cascade do |t|
    t.integer  "external_gateway_id", limit: 4
    t.string   "event_name",          limit: 255
    t.string   "external_network_id", limit: 255
    t.datetime "recorded_at",                     precision: 3
    t.integer  "sync_id",             limit: 4
    t.string   "message_id",          limit: 255
    t.string   "address",             limit: 255
    t.datetime "timestamp"
    t.integer  "minutes_in_state",    limit: 4
    t.integer  "previous_state_id",   limit: 4
    t.integer  "next_state_id",       limit: 4
  end

  add_index "billing_external_gateway_states", ["external_gateway_id"], name: "external_gateway_states", using: :btree
  add_index "billing_external_gateway_states", ["sync_id"], name: "external_gateway_syncs", using: :btree

  create_table "billing_external_gateways", force: :cascade do |t|
    t.string "router_id", limit: 255
    t.string "address",   limit: 255
    t.string "tenant_id", limit: 255
    t.string "name",      limit: 255
  end

  add_index "billing_external_gateways", ["tenant_id"], name: "tenant_external_gateways", using: :btree

  create_table "billing_image_states", force: :cascade do |t|
    t.datetime "recorded_at",                   precision: 3
    t.string   "event_name",        limit: 255
    t.float    "size",              limit: 24
    t.integer  "image_id",          limit: 4
    t.integer  "sync_id",           limit: 4
    t.string   "message_id",        limit: 255
    t.datetime "timestamp"
    t.integer  "minutes_in_state",  limit: 4
    t.integer  "previous_state_id", limit: 4
    t.integer  "next_state_id",     limit: 4
  end

  add_index "billing_image_states", ["image_id"], name: "image_states", using: :btree
  add_index "billing_image_states", ["sync_id"], name: "image_syncs", using: :btree

  create_table "billing_images", force: :cascade do |t|
    t.string "image_id",  limit: 255
    t.string "name",      limit: 255
    t.string "tenant_id", limit: 255
  end

  add_index "billing_images", ["image_id"], name: "index_billing_images_on_image_id", unique: true, using: :btree
  add_index "billing_images", ["tenant_id"], name: "tenant_images", using: :btree

  create_table "billing_instance_flavors", force: :cascade do |t|
    t.string  "flavor_id", limit: 255
    t.string  "name",      limit: 255
    t.integer "ram",       limit: 4
    t.integer "disk",      limit: 4
    t.integer "vcpus",     limit: 4
    t.float   "rate",      limit: 24
  end

  create_table "billing_instance_states", force: :cascade do |t|
    t.integer  "instance_id",       limit: 4
    t.datetime "recorded_at",                   precision: 3
    t.string   "state",             limit: 255
    t.string   "message_id",        limit: 255
    t.string   "event_name",        limit: 255
    t.integer  "sync_id",           limit: 4
    t.string   "flavor_id",         limit: 255
    t.datetime "timestamp"
    t.integer  "minutes_in_state",  limit: 4
    t.integer  "previous_state_id", limit: 4
    t.integer  "next_state_id",     limit: 4
  end

  add_index "billing_instance_states", ["instance_id"], name: "instance_states", using: :btree
  add_index "billing_instance_states", ["sync_id"], name: "instance_syncs", using: :btree

  create_table "billing_instances", force: :cascade do |t|
    t.string "instance_id", limit: 255
    t.string "name",        limit: 255
    t.string "flavor_id",   limit: 255
    t.string "image_id",    limit: 255
    t.string "tenant_id",   limit: 255
    t.string "arch",        limit: 255, default: "x86_64", null: false
  end

  add_index "billing_instances", ["flavor_id"], name: "instance_flavors", using: :btree
  add_index "billing_instances", ["instance_id"], name: "index_billing_instances_on_instance_id", unique: true, using: :btree
  add_index "billing_instances", ["tenant_id"], name: "tenant_instances", using: :btree

  create_table "billing_invoices", force: :cascade do |t|
    t.integer "organization_id",       limit: 4,                 null: false
    t.integer "year",                  limit: 4,                 null: false
    t.integer "month",                 limit: 4,                 null: false
    t.float   "sub_total",             limit: 24,  default: 0.0, null: false
    t.float   "grand_total",           limit: 24,  default: 0.0, null: false
    t.integer "discount_percent",      limit: 4,   default: 0,   null: false
    t.integer "tax_percent",           limit: 4,   default: 20,  null: false
    t.string  "stripe_invoice_id",     limit: 255
    t.string  "salesforce_invoice_id", limit: 255
  end

  create_table "billing_ip_quotas", force: :cascade do |t|
    t.string   "tenant_id",   limit: 255
    t.integer  "quota",       limit: 4
    t.datetime "recorded_at",             precision: 3
    t.integer  "sync_id",     limit: 4
    t.integer  "previous",    limit: 4
  end

  add_index "billing_ip_quotas", ["tenant_id"], name: "tenant_ip_quotas", using: :btree

  create_table "billing_ip_states", force: :cascade do |t|
    t.integer  "ip_id",             limit: 4
    t.string   "event_name",        limit: 255
    t.string   "port",              limit: 255
    t.datetime "recorded_at",                   precision: 3
    t.string   "message_id",        limit: 255
    t.integer  "sync_id",           limit: 4
    t.datetime "timestamp"
    t.integer  "minutes_in_state",  limit: 4
    t.integer  "previous_state_id", limit: 4
    t.integer  "next_state_id",     limit: 4
  end

  add_index "billing_ip_states", ["ip_id"], name: "ip_states", using: :btree
  add_index "billing_ip_states", ["sync_id"], name: "ip_syncs", using: :btree

  create_table "billing_ips", force: :cascade do |t|
    t.string  "ip_id",     limit: 255
    t.string  "address",   limit: 255
    t.string  "tenant_id", limit: 255
    t.boolean "active",                default: true, null: false
  end

  add_index "billing_ips", ["tenant_id"], name: "tenant_ips", using: :btree

  create_table "billing_rates", force: :cascade do |t|
    t.integer "flavor_id", limit: 4
    t.string  "arch",      limit: 255
    t.float   "rate",      limit: 24
    t.boolean "show",                  default: true, null: false
  end

  create_table "billing_storage_objects", force: :cascade do |t|
    t.string   "tenant_id",   limit: 255
    t.integer  "size",        limit: 8
    t.datetime "recorded_at",             precision: 3
    t.integer  "sync_id",     limit: 4
  end

  add_index "billing_storage_objects", ["tenant_id"], name: "tenant_storage_objects", using: :btree

  create_table "billing_syncs", force: :cascade do |t|
    t.datetime "completed_at", precision: 3
    t.datetime "started_at",   precision: 3
  end

  create_table "billing_volume_states", force: :cascade do |t|
    t.datetime "recorded_at",                   precision: 3
    t.string   "event_name",        limit: 255
    t.integer  "size",              limit: 4
    t.integer  "volume_id",         limit: 4
    t.string   "message_id",        limit: 255
    t.integer  "sync_id",           limit: 4
    t.datetime "timestamp"
    t.integer  "minutes_in_state",  limit: 4
    t.integer  "previous_state_id", limit: 4
    t.integer  "next_state_id",     limit: 4
  end

  add_index "billing_volume_states", ["sync_id"], name: "volume_syncs", using: :btree
  add_index "billing_volume_states", ["volume_id"], name: "volume_states", using: :btree

  create_table "billing_volumes", force: :cascade do |t|
    t.string "volume_id", limit: 255
    t.string "name",      limit: 255
    t.string "tenant_id", limit: 255
  end

  add_index "billing_volumes", ["tenant_id"], name: "tenant_volumes", using: :btree
  add_index "billing_volumes", ["volume_id"], name: "index_billing_volumes_on_volume_id", unique: true, using: :btree

  create_table "customer_signups", force: :cascade do |t|
    t.string   "uuid",                limit: 255
    t.string   "email",               limit: 255
    t.string   "organization_name",   limit: 255
    t.string   "stripe_customer_id",  limit: 255
    t.string   "ip_address",          limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "reminder_sent",                   default: false, null: false
    t.string   "discount_code",       limit: 255
    t.string   "real_ip",             limit: 255
    t.string   "forwarded_ip",        limit: 255
    t.string   "device_id",           limit: 255
    t.integer  "activation_attempts", limit: 4,   default: 0,     null: false
    t.string   "user_agent",          limit: 255
    t.string   "accept_language",     limit: 255
    t.boolean  "retro_migrated"
  end

  create_table "invites", force: :cascade do |t|
    t.string   "email",              limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "completed_at"
    t.string   "token",              limit: 255
    t.integer  "organization_id",    limit: 4
    t.boolean  "power_invite",                   default: false, null: false
    t.integer  "customer_signup_id", limit: 4
    t.string   "remote_message_id",  limit: 255
  end

  create_table "invites_roles", force: :cascade do |t|
    t.integer  "role_id",    limit: 4
    t.integer  "invite_id",  limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "invites_tenants", force: :cascade do |t|
    t.integer  "invite_id",  limit: 4
    t.integer  "tenant_id",  limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "organization_vouchers", force: :cascade do |t|
    t.integer  "organization_id", limit: 4
    t.integer  "voucher_id",      limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "organization_vouchers", ["organization_id", "voucher_id"], name: "index_organization_vouchers_on_organization_id_and_voucher_id", unique: true, using: :btree

  create_table "organizations", force: :cascade do |t|
    t.string   "reference",          limit: 255
    t.string   "name",               limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "time_zone",          limit: 255, default: "London", null: false
    t.string   "locale",             limit: 255, default: "en",     null: false
    t.integer  "primary_tenant_id",  limit: 4
    t.datetime "started_paying_at"
    t.string   "stripe_customer_id", limit: 255
    t.boolean  "self_service",                   default: true,     null: false
    t.string   "salesforce_id",      limit: 255
    t.string   "billing_address1",   limit: 255
    t.string   "billing_address2",   limit: 255
    t.string   "billing_city",       limit: 255
    t.string   "billing_postcode",   limit: 255
    t.string   "billing_country",    limit: 255
    t.string   "phone",              limit: 255
    t.integer  "customer_signup_id", limit: 4
    t.string   "state",              limit: 255, default: "active", null: false
    t.boolean  "disabled",                       default: false,    null: false
    t.boolean  "test_account",                   default: false,    null: false
    t.string   "reporting_code",     limit: 255
    t.boolean  "in_review",                      default: false,    null: false
    t.boolean  "limited_storage",                default: false,    null: false
    t.integer  "projects_limit",     limit: 4,   default: 1,        null: false
    t.float    "weekly_spend",       limit: 24,  default: 0.0,      null: false
  end

  add_index "organizations", ["reporting_code"], name: "index_organizations_on_reporting_code", unique: true, using: :btree

  create_table "organizations_products", force: :cascade do |t|
    t.integer  "organization_id", limit: 4
    t.integer  "product_id",      limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "products", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "resets", force: :cascade do |t|
    t.string   "email",        limit: 255
    t.string   "token",        limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "completed_at"
  end

  create_table "roles", force: :cascade do |t|
    t.string   "name",            limit: 255
    t.text     "permissions",     limit: 65535
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "power_user",                    default: false
    t.integer  "organization_id", limit: 4
  end

  create_table "roles_users", force: :cascade do |t|
    t.integer  "role_id",    limit: 4
    t.integer  "user_id",    limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "starburst_announcement_views", force: :cascade do |t|
    t.integer  "user_id",         limit: 4
    t.integer  "announcement_id", limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "starburst_announcement_views", ["user_id", "announcement_id"], name: "starburst_announcement_view_index", unique: true, using: :btree

  create_table "starburst_announcements", force: :cascade do |t|
    t.text     "title",               limit: 65535
    t.text     "body",                limit: 65535
    t.datetime "start_delivering_at"
    t.datetime "stop_delivering_at"
    t.text     "limit_to_users",      limit: 65535
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "category",            limit: 65535
  end

  create_table "tenants", force: :cascade do |t|
    t.string  "name",            limit: 255
    t.string  "uuid",            limit: 255
    t.integer "organization_id", limit: 4
  end

  create_table "user_tenant_roles", force: :cascade do |t|
    t.integer "user_id",   limit: 4
    t.integer "tenant_id", limit: 4
    t.string  "role_uuid", limit: 255
  end

  add_index "user_tenant_roles", ["user_id", "tenant_id", "role_uuid"], name: "index_user_tenant_roles_on_user_id_and_tenant_id_and_role_uuid", unique: true, using: :btree

  create_table "users", force: :cascade do |t|
    t.string   "email",           limit: 255
    t.string   "first_name",      limit: 255
    t.string   "last_name",       limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "organization_id", limit: 4
    t.string   "uuid",            limit: 255
    t.string   "password_digest", limit: 255
  end

  create_table "vouchers", force: :cascade do |t|
    t.string   "name",             limit: 255,                               null: false
    t.string   "description",      limit: 255,                               null: false
    t.string   "code",             limit: 255,                               null: false
    t.integer  "duration",         limit: 1,                 default: 1,     null: false
    t.decimal  "discount_percent",             precision: 3, default: 10,    null: false
    t.datetime "expires_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "usage_limit",      limit: 4
    t.boolean  "restricted",                                 default: false, null: false
  end

  add_index "vouchers", ["code"], name: "index_vouchers_on_code", unique: true, using: :btree

  create_table "wait_list_entries", force: :cascade do |t|
    t.string   "email",      limit: 255
    t.datetime "emailed_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
