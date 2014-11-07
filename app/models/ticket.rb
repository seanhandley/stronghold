class Ticket
  include ActiveModel::Validations
  
  attr_accessor :reference, :title,  :description, :created_at, :updated_at,
                :comments,  :status, :name, :email, :department, :priority,
                :as_hash

  validates :title,       length: {minimum: 1, maximum: 200}, allow_blank: false, unless: :access_request?
  validates :description, length: {minimum: 1}, allow_blank: false, unless: :access_request?
  validates :department, :priority, :presence => true

  def initialize(params)
    @reference   = params[:reference]
    @title       = params[:title]
    @description = params[:description]
    @department  = params[:department]
    @priority    = params[:priority]
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

  def access_request?
    department == "Access Requests"
  end

  def status_name
    return 'Open' unless @status
    @status['status_type'] == 1 ? 'Closed' : 'Open'
  end

end
