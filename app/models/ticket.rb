class Ticket
  include ActiveModel::Validations
  
  attr_accessor :reference, :title,  :description, :created_at, :updated_at,
                :comments,  :status, :name, :email, :department,
                :as_hash

  validates :title, :description, length: {minimum: 1}, allow_blank: false

  def initialize(params)
    @reference   = params[:reference]
    @title       = params[:title]
    @description = params[:description]
    @department  = params[:department]
    @created_at  = params[:created_at]
    @updated_at  = params[:updated_at]
    @comments    = params[:comments] || []
    @email       = params[:email]
    @name        = params[:name]
    @status      = params[:status]
    @as_hash     = params.dup.merge(comments: @comments.map{|c| c.as_hash },
                                    status_name: status_name)
  end

  def self.find(params)
    nil
  end

  def status_name
    return 'Open' unless @status
    @status['status_type'] == 1 ? 'Closed' : 'Open'
  end

end

# {
#   "id"=>109,
#   "reference"=>"UY-969571",
#   "subject"=>"Test support ticket",
#   "message_id"=>"df677042-2312-c14f-9259-deb6dd367e13@helpdesk.datacentred.io",
#   "submitted_at"=>"2014-09-15T11:02:15Z",
#   "updated_at"=>"2014-09-15T20:24:09Z",
#   "reply_due_at"=>nil,
#   "resolution_due_at"=>nil,
#   "auth_code"=>"x91pxnh8albi",
#   "last_update_posted_at"=>"2014-09-15T11:07:36Z",
#   "first_response_time"=>"4.17",
#   "first_resolution_time"=>"561.91",
#   "resolution_time"=>"561.91",
#   "last_respondant"=>"contact",
#   "update_count"=>6,
#   "status"=>{
#     "id"=>4,
#     "name"=>"Resolved",
#     "colour"=>"9c9c9c",
#     "status_type"=>1
#   },
#   "priority"=>{
#     "id"=>1,
#     "name"=>"Normal",
#     "colour"=>"0097cf",
#     "position"=>1
#   },
#   "department"=>{
#     "id"=>3,
#     "name"=>"Support",
#     "brand"=>{
#       "id"=>1,
#       "name"=>"DataCentred",
#       "url"=>"http://www.datacentred.co.uk",
#       "phone"=>"0161 870 3981"
#     },
#     "private"=>false
#   },
#   "team"=>{
#     "id"=>1,
#     "name"=>"Platform"
#   },
#   "user"=>{
#     "id"=>2,
#     "username"=>"sean",
#     "first_name"=>"Sean",
#     "last_name"=>"Handley",
#     "job_title"=>"Cloud Application Engineer",
#     "avatar_url"=>"https://secure.gravatar.com/avatar/4698fbceb648a8251a072b67de7c9db4?rating=PG&size={{size}}&d=mm"
#   },
#   "sla"=>nil,
#   "additional_contact_methods"=>[],
#   "source"=>{
#     "id"=>1,
#     "address"=>"support@datacentred.co.uk",
#     "name"=>"DataCentred Support",
#     "allow_outbound"=>true,
#     "subject_prefix"=>"",
#     "send_as_user"=>false,
#     "test_enabled"=>false,
#     "type"=>"IncomingAddress"
#   },
#   "tags"=>[],
#   "customer"=>{
#     "id"=>3, "reference"=>"",
#     "name"=>"Rob Greenwood",
#     "abbreviated_name"=>"Rob G",
#     "company"=>"",
#     "mail_format"=>"both",
#     "picture_url"=>"https://secure.gravatar.com/avatar/8ab67cbe0b02a7338bca07a4a4bff4f6?rating=PG&size=90&default=blah",
#     "discussion_count"=>1,
#     "pin"=>"941645",
#     "created_at"=>"2014-09-15T11:02:15Z"
#   },
#   "customer_contact_method"=>{
#     "id"=>4,
#     "method_type"=>"email",
#     "data"=>"bilco105@gmail.com",
#     "default"=>true
#   }
# }