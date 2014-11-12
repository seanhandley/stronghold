class Ticket
  include ActiveModel::Validations
  
  attr_accessor :reference, :title,  :description, :created_at, :updated_at,
                :comments,  :status, :name, :email, :department, :priority,
                :visitor_names, :nature_of_visit, :date_of_visit, :time_of_visit,
                :as_hash

  validates :title,       length: {minimum: 1, maximum: 200}, allow_blank: false, unless: :access_request?
  validates :description, length: {minimum: 1}, allow_blank: false, unless: :access_request?
  validates :department, :priority, :presence => true
  validates :visitor_names, :nature_of_visit, :date_of_visit, :time_of_visit, length: {minimum: 1}, allow_blank: false, if: :access_request?

  def initialize(params)
    @reference       = params[:reference]  
    @description     = params[:description]
    @department      = params[:department]
    @title           = access_request? ? 'Access Request' : params[:title]
    @priority        = params[:priority]
    @created_at      = params[:created_at]
    @updated_at      = params[:updated_at]
    @comments        = params[:comments] || []
    @email           = params[:email]
    @name            = params[:name]
    @status          = params[:status]
    @visitor_names   = params[:visitor_names]
    @nature_of_visit = params[:nature_of_visit]
    @date_of_visit   = params[:date_of_visit]
    @time_of_visit   = params[:time_of_visit]
    @as_hash         = params.dup.merge(comments: @comments.map{|c| c.as_hash },
                                    status_name: status_name)
  end

  def self.find(params)
    nil
  end

  def access_request?
    @department == "Access Requests"
  end

  def status_name
    return 'Open' unless @status
    @status['status_type'] == 1 ? 'Closed' : 'Open'
  end

end
