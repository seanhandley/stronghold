class Ticket
  include ActiveModel::Validations
  
  attr_accessor :reference, :title,  :description, :created_at, :updated_at,
                :comments,  :status, :name, :email, :department, :priority,
                :visitor_names, :nature_of_visit, :date_of_visit, :time_of_visit,
                :as_hash

  validates :title,       length: {minimum: 1, maximum: 200}, allow_blank: false, unless: :access_request?
  validates :description, length: {minimum: 1}, allow_blank: false, unless: :access_request?
  validates :department, :priority, :presence => true
  validates :nature_of_visit, length: {minimum: 1}, allow_blank: false, if: :access_request?
  validate :date_time_of_visit, if: :access_request?

  def initialize(params)
    @reference       = params[:reference]  
    @department      = params[:department]
    @title           = access_request? ? 'Access Request' : params[:title]
    @description     = access_request? ? params[:nature_of_visit] : params[:description]
    @priority        = params[:priority]
    @created_at      = params[:created_at]
    @updated_at      = params[:updated_at]
    @comments        = params[:comments] || []
    @email           = params[:email]
    @name            = params[:name]
    @status          = params[:status]
    @visitor_names   = params[:visitor_names] || params[:name]
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
    @status == 1 ? 'Closed' : 'Open'
  end

  private

  def date_time_of_visit
    time_valid, date_valid = true, true
    begin
      Date.parse(@date_of_visit)
      date_valid = false unless @date_of_visit.split('/').all?{|e| e.to_i > 0 }
    rescue ArgumentError
      date_valid = false
    end

    begin
      Time.parse(@time_of_visit)
      time_valid = false unless @time_of_visit.split(':').all?{|e| e != 'null' }
    rescue ArgumentError
      time_valid = false
    end

    errors.add(:time_of_visit, "is not a valid time") unless time_valid
    errors.add(:date_of_visit, "is not a valid date") unless date_valid
    if time_valid && date_valid
       unless DateTime.parse("#{@date_of_visit} #{@time_of_visit}").future?
         errors.add("Date/Time", "is not in the future")
       end
    end
  end

end
