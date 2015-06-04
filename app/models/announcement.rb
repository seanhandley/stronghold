class Announcement
  def self.create(params)
    body = "<strong><i class='fa fa-bullhorn'></i> #{params[:title]}:</strong> #{params[:body]}".html_safe
    args = {body: body}
    if params[:limit_field]
      args.merge!(:limit_to_users => 
      [
          {
              :field => params[:limit_field],
              :value => params[:limit_value]
          }
      ])
    end

    Starburst::Announcement.create(args)
  end
end
