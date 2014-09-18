class TicketComment

  include ActiveModel::Validations
  validates :text, length: {minimum: 1}, allow_blank: false

  attr_accessor :ticket_reference, :id, :email, :text, :time, :as_hash, :staff

  def initialize(params)
    @as_hash          = params.dup
    @ticket_reference = params[:ticket_reference]
    @id               = params[:id]
    @email            = params[:email]
    @text             = params[:text]
    @time             = params[:time]
    @staff            = params[:staff]
  end

end

# {
#   "id"=>116,
#   "subject"=>"Test support ticket",
#   "message"=>"Things are b0rk :(",
#   "html_body"=>"<html><head><style>body{font-family:Helvetica,Arial;font-size:13px}</style></head><body style=\"word-wrap: break-word; -webkit-nbsp-mode: space; -webkit-line-break: after-white-space;\"><div id=\"bloop_customfont\" style=\"font-family:Helvetica,Arial;font-size:13px; color: rgba(0,0,0,1.0); margin: 0px; line-height: auto;\">Things are b0rk :(</div></body></html>",
#   "html_safe"=>false,
#   "private"=>false,
#   "posted_at"=>"2014-09-15T11:02:15Z",
#   "avatar_url"=>"https://secure.gravatar.com/avatar/8ab67cbe0b02a7338bca07a4a4bff4f6?rating=PG&size={{size}}&d=mm",
#   "author"=>{
#     "type"=>"Customer",
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
#   "from_name"=>"Rob Greenwood",
#   "from_address"=>"bilco105@gmail.com",
#   "minutes_since_reply_due"=>nil,
#   "minutes_since_resolution_due"=>nil,
#   "minutes_since_submission"=>"0.01",
#   "minutes_since_last_reply"=>nil, 
#   "signature_text"=>nil,
#   "stripped_content"=>nil,
#   "authenticated"=>false,
#   "message_id"=>"etPan.5416c729.79838cb2.22a@Robs-MacBook-Pro.local",
#   "attachments"=>[],
#   "source"=>nil,
#   "notification_sent"=>nil,
#   "delivered"=>nil
# }