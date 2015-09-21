unless true || Rails.env.test? || Rails.env.acceptance?
  begin
    RailsAdmin.config do |config|

      ### Popular gems integration

      ## == Devise ==
      # config.authenticate_with do
      #   Authorization.current_user
      # end
      config.current_user_method(&:current_user)

      ## == Cancan ==
      config.authorize_with :cancan, User::Ability

      ## == PaperTrail ==
      # config.audit_with :paper_trail, 'User', 'PaperTrail::Version' # PaperTrail >= 3.0.0

      ### More at https://github.com/sferik/rails_admin/wiki/Base-configuration

      config.actions do
        dashboard                     # mandatory
        index                         # mandatory
        new
        export
        bulk_delete
        show
        edit
        delete
        show_in_app

        ## With an audit adapter, you can add:
        # history_index
        # history_show
      end
    end
  rescue StandardError => e
    puts "Couldn't load rails admin. Is the db schema in tact?"
  end
end