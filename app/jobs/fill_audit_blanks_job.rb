class FillAuditBlanksJob < ApplicationJob
  queue_as :default

  def perform
    Audit.where(organization_id: nil).includes(:user).each do |audit|
      if audit.user
        audit.update_column(:organization_id, audit.user.primary_organization.id)
      elsif audit.audited_changes && (organization_id = audit.audited_changes['organization_id'])
        audit.update_column(:organization_id, organization_id)
      end
    end
  end
end
