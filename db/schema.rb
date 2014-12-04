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

ActiveRecord::Schema.define(version: 20141204122505) do

  create_table "audits", force: true do |t|
    t.string   "auditable_id"
    t.string   "auditable_type"
    t.integer  "associated_id"
    t.string   "associated_type"
    t.integer  "user_id"
    t.string   "user_type"
    t.string   "username"
    t.string   "action"
    t.text     "audited_changes"
    t.integer  "version",         default: 0
    t.string   "comment"
    t.string   "remote_address"
    t.datetime "created_at"
    t.integer  "organization_id"
  end

  add_index "audits", ["associated_id", "associated_type"], name: "associated_index", using: :btree
  add_index "audits", ["auditable_id", "auditable_type"], name: "auditable_index", using: :btree
  add_index "audits", ["created_at"], name: "index_audits_on_created_at", using: :btree
  add_index "audits", ["organization_id"], name: "index_audits_on_organization_id", using: :btree
  add_index "audits", ["user_id", "user_type"], name: "user_index", using: :btree

  create_table "billing_external_gateway_states", force: true do |t|
    t.integer  "external_gateway_id"
    t.string   "event_name"
    t.string   "external_network_id"
    t.datetime "recorded_at",         limit: 3
    t.integer  "sync_id"
    t.string   "message_id"
    t.string   "address"
  end

  create_table "billing_external_gateways", force: true do |t|
    t.string "router_id"
    t.string "address"
    t.string "tenant_id"
    t.string "name"
  end

  create_table "billing_image_states", force: true do |t|
    t.datetime "recorded_at", limit: 3
    t.string   "event_name"
    t.integer  "size"
    t.integer  "image_id"
    t.integer  "sync_id"
    t.string   "message_id"
  end

  create_table "billing_images", force: true do |t|
    t.string "image_id"
    t.string "name"
    t.string "tenant_id"
  end

  create_table "billing_instance_flavors", force: true do |t|
    t.string  "flavor_id"
    t.string  "name"
    t.integer "ram"
    t.integer "disk"
    t.integer "vcpus"
  end

  create_table "billing_instance_states", force: true do |t|
    t.integer  "instance_id"
    t.datetime "recorded_at", limit: 3
    t.string   "state"
    t.string   "message_id"
    t.string   "event_name"
    t.integer  "sync_id"
  end

  create_table "billing_instances", force: true do |t|
    t.string "instance_id"
    t.string "name"
    t.string "flavor_id"
    t.string "image_id"
    t.string "tenant_id"
  end

  create_table "billing_ip_states", force: true do |t|
    t.integer  "ip_id"
    t.string   "event_name"
    t.string   "port"
    t.datetime "recorded_at", limit: 3
    t.string   "message_id"
    t.integer  "sync_id"
  end

  create_table "billing_ips", force: true do |t|
    t.string  "ip_id"
    t.string  "address"
    t.string  "tenant_id"
    t.boolean "active",    default: true, null: false
  end

  create_table "billing_syncs", force: true do |t|
    t.datetime "completed_at", limit: 3
    t.datetime "started_at",   limit: 3
  end

  create_table "billing_volume_states", force: true do |t|
    t.datetime "recorded_at", limit: 3
    t.string   "event_name"
    t.integer  "size"
    t.integer  "volume_id"
    t.string   "message_id"
    t.integer  "sync_id"
  end

  create_table "billing_volumes", force: true do |t|
    t.string "volume_id"
    t.string "name"
    t.string "tenant_id"
  end

  create_table "invites", force: true do |t|
    t.string   "email"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "completed_at"
    t.string   "token"
    t.integer  "organization_id"
    t.boolean  "power_invite",    default: false, null: false
  end

  create_table "invites_roles", force: true do |t|
    t.integer  "role_id"
    t.integer  "invite_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "organizations", force: true do |t|
    t.string   "reference"
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "time_zone",         default: "London", null: false
    t.string   "locale",            default: "en",     null: false
    t.integer  "primary_tenant_id"
  end

  create_table "organizations_products", force: true do |t|
    t.integer  "organization_id"
    t.integer  "product_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "products", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "resets", force: true do |t|
    t.string   "email"
    t.string   "token"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "completed_at"
  end

  create_table "roles", force: true do |t|
    t.string   "name"
    t.text     "permissions"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "power_user",      default: false
    t.integer  "organization_id"
  end

  create_table "roles_users", force: true do |t|
    t.integer  "role_id"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "tenants", force: true do |t|
    t.string  "name"
    t.string  "uuid"
    t.integer "organization_id"
  end

  create_table "user_tenant_roles", force: true do |t|
    t.integer "user_id"
    t.integer "tenant_id"
    t.string  "role_uuid"
  end

  create_table "users", force: true do |t|
    t.string   "email"
    t.string   "first_name"
    t.string   "last_name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "organization_id"
    t.string   "uuid"
  end

end
