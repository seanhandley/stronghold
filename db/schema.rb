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

ActiveRecord::Schema.define(version: 20150303114455) do

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
    t.datetime "recorded_at",         limit: 3
    t.integer  "sync_id",             limit: 4
    t.string   "message_id",          limit: 255
    t.string   "address",             limit: 255
  end

  add_index "billing_external_gateway_states", ["external_gateway_id"], name: "external_gateway_states", using: :btree
  add_index "billing_external_gateway_states", ["sync_id"], name: "external_gateway_syncs", using: :btree

  create_table "billing_external_gateways", force: :cascade do |t|
    t.string "router_id", limit: 255
    t.string "address",   limit: 255
    t.string "tenant_id", limit: 255
    t.string "name",      limit: 255
  end

  create_table "billing_image_states", force: :cascade do |t|
    t.datetime "recorded_at", limit: 3
    t.string   "event_name",  limit: 255
    t.float    "size",        limit: 24
    t.integer  "image_id",    limit: 4
    t.integer  "sync_id",     limit: 4
    t.string   "message_id",  limit: 255
  end

  add_index "billing_image_states", ["image_id"], name: "image_states", using: :btree
  add_index "billing_image_states", ["sync_id"], name: "image_syncs", using: :btree

  create_table "billing_images", force: :cascade do |t|
    t.string "image_id",  limit: 255
    t.string "name",      limit: 255
    t.string "tenant_id", limit: 255
  end

  create_table "billing_instance_flavors", force: :cascade do |t|
    t.string  "flavor_id", limit: 255
    t.string  "name",      limit: 255
    t.integer "ram",       limit: 4
    t.integer "disk",      limit: 4
    t.integer "vcpus",     limit: 4
  end

  create_table "billing_instance_states", force: :cascade do |t|
    t.integer  "instance_id", limit: 4
    t.datetime "recorded_at", limit: 3
    t.string   "state",       limit: 255
    t.string   "message_id",  limit: 255
    t.string   "event_name",  limit: 255
    t.integer  "sync_id",     limit: 4
  end

  add_index "billing_instance_states", ["instance_id"], name: "instance_states", using: :btree
  add_index "billing_instance_states", ["sync_id"], name: "instance_syncs", using: :btree

  create_table "billing_instances", force: :cascade do |t|
    t.string "instance_id", limit: 255
    t.string "name",        limit: 255
    t.string "flavor_id",   limit: 255
    t.string "image_id",    limit: 255
    t.string "tenant_id",   limit: 255
  end

  add_index "billing_instances", ["flavor_id"], name: "instance_flavors", using: :btree

  create_table "billing_ip_states", force: :cascade do |t|
    t.integer  "ip_id",       limit: 4
    t.string   "event_name",  limit: 255
    t.string   "port",        limit: 255
    t.datetime "recorded_at", limit: 3
    t.string   "message_id",  limit: 255
    t.integer  "sync_id",     limit: 4
  end

  add_index "billing_ip_states", ["ip_id"], name: "ip_states", using: :btree
  add_index "billing_ip_states", ["sync_id"], name: "ip_syncs", using: :btree

  create_table "billing_ips", force: :cascade do |t|
    t.string  "ip_id",     limit: 255
    t.string  "address",   limit: 255
    t.string  "tenant_id", limit: 255
    t.boolean "active",    limit: 1,   default: true, null: false
  end

  create_table "billing_storage_objects", force: :cascade do |t|
    t.string   "tenant_id",   limit: 255
    t.integer  "size",        limit: 8
    t.datetime "recorded_at", limit: 3
    t.integer  "sync_id",     limit: 4
  end

  create_table "billing_syncs", force: :cascade do |t|
    t.datetime "completed_at", limit: 3
    t.datetime "started_at",   limit: 3
  end

  create_table "billing_volume_states", force: :cascade do |t|
    t.datetime "recorded_at", limit: 3
    t.string   "event_name",  limit: 255
    t.integer  "size",        limit: 4
    t.integer  "volume_id",   limit: 4
    t.string   "message_id",  limit: 255
    t.integer  "sync_id",     limit: 4
  end

  add_index "billing_volume_states", ["sync_id"], name: "volume_syncs", using: :btree
  add_index "billing_volume_states", ["volume_id"], name: "volume_states", using: :btree

  create_table "billing_volumes", force: :cascade do |t|
    t.string "volume_id", limit: 255
    t.string "name",      limit: 255
    t.string "tenant_id", limit: 255
  end

  create_table "invites", force: :cascade do |t|
    t.string   "email",           limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "completed_at"
    t.string   "token",           limit: 255
    t.integer  "organization_id", limit: 4
    t.boolean  "power_invite",    limit: 1,   default: false, null: false
  end

  create_table "invites_roles", force: :cascade do |t|
    t.integer  "role_id",    limit: 4
    t.integer  "invite_id",  limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "organizations", force: :cascade do |t|
    t.string   "reference",         limit: 255
    t.string   "name",              limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "time_zone",         limit: 255, default: "London", null: false
    t.string   "locale",            limit: 255, default: "en",     null: false
    t.integer  "primary_tenant_id", limit: 4
    t.datetime "started_paying_at"
  end

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
    t.boolean  "power_user",      limit: 1,     default: false
    t.integer  "organization_id", limit: 4
  end

  create_table "roles_users", force: :cascade do |t|
    t.integer  "role_id",    limit: 4
    t.integer  "user_id",    limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
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

  create_table "users", force: :cascade do |t|
    t.string   "email",           limit: 255
    t.string   "first_name",      limit: 255
    t.string   "last_name",       limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "organization_id", limit: 4
    t.string   "uuid",            limit: 255
  end

end
