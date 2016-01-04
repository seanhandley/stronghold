module StarburstHelper
  def starburst_params(params)
    body = "<strong><i class='fa fa-bullhorn'></i> #{params[:title]}:</strong> #{params[:body]}".html_safe
    start_delivering_at = "#{params[:start_delivering_at_date]}"+" "+"#{params[:start_delivering_at_time]}"
    stop_delivering_at = "#{params[:stop_delivering_at_date]}"+" "+"#{params[:stop_delivering_at_time]}"
    args = {body: body, start_delivering_at: start_delivering_at, stop_delivering_at: stop_delivering_at}
    if params[:filters]
      filters = params[:filters].to_h.map do |field_name,_|
        {
          :field => field_name,
          :value => true
        }
      end
      args.merge! limit_to_users: filters
    end
    args
  end
end
