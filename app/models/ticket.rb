class Ticket
  include TicketsHelper

  include ActiveModel::Validations
  validates :title, :description, length: {minimum: 1}, allow_blank: false

  attr_accessor :reference, :title, :email, :description, :time_created, :time_updated, :comments, :status_name

  def initialize(params)
    @title = params[:title]
    @description = params[:description]
    @email = Authorization.current_user.email
    @time_created = nil
    @time_updated = nil
    @comments = []
  end

  def self.find(params)
    nil
  end

end