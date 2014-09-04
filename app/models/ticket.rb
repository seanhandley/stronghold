class Ticket

  include ApplicationHelper
  include ActiveModel::Validations
  validates :title, :description, length: {minimum: 1}, allow_blank: false

  attr_accessor :reference, :title, :email, :description, :time_created, :time_updated, :comments, :status_name, :display_name

  def initialize(params)
    @title = params[:title]
    @description = params[:description]
    set_email(Authorization.current_user.email)
    @time_created = nil
    @time_updated = nil
    @comments = []
  end

  def set_email(email)
    @email = email
    @display_name = email_to_display_name(email)
  end

  def self.find(params)
    nil
  end

end