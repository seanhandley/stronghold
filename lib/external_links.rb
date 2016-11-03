module ExternalLinks
  def self.cookie_documentation_path
    'https://docs.datacentred.io/pages/viewpage.action?pageId=2588675'
  end
  def self.terms_of_service_path
    'http://www.datacentred.co.uk/terms-of-service/'
  end
  def self.getting_started_path
    'https://docs.datacentred.io/x/WQAJ'
  end
  def self.documentation_path
    'http://docs.datacentred.io'
  end
  def self.status_path
    'http://status.datacentred.io'
  end
  def self.ticket_path(reference)
    "https://helpdesk.datacentred.io/staff/tickets/#{reference}"
  end
  def self.python_openstack_client_docs_path
    'http://docs.openstack.org/user-guide/common/cli-install-openstack-command-line-clients.html'
  end
  def self.vagrant_openstack_client
    'https://github.com/datacentred/openstack-cli-vagrant'
  end
  def self.github_mastering_markdown
    'https://guides.github.com/features/mastering-markdown/'
  end
  def self.salesforce_invoice_path(salesforce_id)
    "https://eu2.salesforce.com/#{salesforce_id}"
  end
  def self.stripe_path(section, id)
    "https://dashboard.stripe.com/#{section}/#{id}"
  end
end
