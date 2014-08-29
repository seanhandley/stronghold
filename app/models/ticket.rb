class Ticket
  include TicketsHelper

  attr_accessor :reference, :title, :email, :description, :time_created, :time_updated, :comments

  def initialize(reference, title, email, description, status_name)
    @reference = reference
    @title = title
    @email = email
    @description = description
    @time_created = nil
    @time_updated = nil
    @comments = []
    @status_name = status_name
    rescue
  end

  def self.find(params)
    nil
  end

end