class Ticket
  include ActiveModel::Validations
  
  attr_accessor :reference, :title,  :description, :created_at, :updated_at,
                :comments,  :status, :name, :email, :department,
                :as_hash

  validates :title,       length: {minimum: 1, maximum: 200}, allow_blank: false
  validates :description, length: {minimum: 1}, allow_blank: false
  validates :department, :presence => true

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
