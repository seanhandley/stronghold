module Billing
  class Invoice < ActiveRecord::Base

    self.table_name = "billing_invoices"

    syncs_with_salesforce as: 'c2g__codaInvoice__c', actions: [:create]

    def salesforce_args
      {
        c2g__Account__c: organization.salesforce_id,
        c2g__InvoiceDate__c: period_start.to_date,
        c2g__DueDate__c: (period_start + 1.month).to_date,
        c2g__InvoiceDescription__c: "Cloud services #{Date::MONTHNAMES[month]} #{year}",
        c2g__CustomerReference__c: organization.reporting_code,
        c2g__InvoiceCurrency__c: SALESFORCE_CURRENCY_GBP,
        c2g__DerivePeriod__c: true,
        c2g__DeriveCurrency__c: true,
        c2g__OwnerCompany__c: SALESFORCE_OWNER_COMPANY
      }
    end

    belongs_to :organization

    validates :organization, :year, :month, presence: true

    scope :unfinalized, -> { where(finalized: false) }
    scope :finalized, -> {   where(finalized: true) }

    has_many :billing_line_items, :class_name => "Billing::LineItem",
             :foreign_key => 'invoice_id'

    def build_line_items(usage_data)
      block_storage_product     = SALESFORCE_PRODUCT_MAPPINGS['block_storage']['salesforce_id']
      ssd_block_storage_product = SALESFORCE_PRODUCT_MAPPINGS['ssd_block_storage']['salesforce_id']
      object_storage_product    = SALESFORCE_PRODUCT_MAPPINGS['object_storage']['salesforce_id']
      ip_addresses_product      = SALESFORCE_PRODUCT_MAPPINGS['ip_addresses']['salesforce_id']
      vpn_connection_product    = SALESFORCE_PRODUCT_MAPPINGS['vpn_connection']['salesforce_id']
      load_balancer_product     = SALESFORCE_PRODUCT_MAPPINGS['load_balancer']['salesforce_id']

      instance_flavor_hours          = {}
      windows_instance_flavor_hours  = {}
      block_storage_total            = 0
      ssd_block_storage_total        = 0
      ip_addresses_total             = 0
      object_storage_total           = 0
      vpn_connection_total           = 0
      load_balancer_total            = 0

      usage_data.each do |project, usages|

        usages[:instance_usage].each do |instance|
          instance[:billable_hours].each do |flavor_id, hours|
            if instance[:windows]
              windows_instance_flavor_hours[flavor_id] ||= 0
              windows_instance_flavor_hours[flavor_id] += hours.ceil
            else
              instance_flavor_hours[flavor_id] ||= 0
              instance_flavor_hours[flavor_id] += hours.ceil
            end
          end
        end

        volume_tbh     = usages[:volume_usage].reject{|volume| volume[:ssd]}.sum {|volume| volume[:terabyte_hours]}
        ssd_volume_tbh = usages[:volume_usage].select{|volume| volume[:ssd]}.sum {|volume| volume[:terabyte_hours]}
        image_tbh      = usages[:image_usage].sum  {|image| image[:terabyte_hours]}

        block_storage_total     += (volume_tbh + image_tbh)
        ssd_block_storage_total += ssd_volume_tbh

        object_storage_total += usages[:object_storage_usage]
        ip_addresses_total   += usages[:ip_quota_hours]
        vpn_connection_total += usages[:vpn_connection_usage].sum {|v| v[:hours]}
        load_balancer_total  += usages[:load_balancer_usage].sum  {|v| v[:hours]}
      end

      # Add line items
      billing_line_items.create(product_id: ip_addresses_product,      quantity: ip_addresses_total.ceil)      if ip_addresses_total      > 0
      billing_line_items.create(product_id: block_storage_product,     quantity: block_storage_total.ceil)     if block_storage_total     > 0
      billing_line_items.create(product_id: object_storage_product,    quantity: object_storage_total.ceil)    if object_storage_total    > 0
      billing_line_items.create(product_id: ssd_block_storage_product, quantity: ssd_block_storage_total.ceil) if ssd_block_storage_total > 0
      billing_line_items.create(product_id: vpn_connection_product ,   quantity: vpn_connection_total.ceil)    if vpn_connection_total    > 0
      billing_line_items.create(product_id: load_balancer_product,     quantity: load_balancer_total.ceil)     if load_balancer_total     > 0

      instance_flavor_hours.each do |flavor_id, hours|
        product = Salesforce.find_instance_product(flavor_id)
        if product
          product_id = product['salesforce_id']
          billing_line_items.create(product_id: product_id, quantity: hours)
        else
          Honeybadger.notify(ArgumentError.new("No Salesforce product found for Flavor #{flavor_id}"))
        end
      end

      windows_instance_flavor_hours.each do |flavor_id, hours|
        product = Salesforce.find_instance_product(flavor_id, windows: true)
        if product
          product_id = product['salesforce_id']
          billing_line_items.create(product_id: product_id, quantity: hours)
        else
          Honeybadger.notify(ArgumentError.new("No Windows Salesforce product found for Flavor #{flavor_id}"))
        end
      end
      true
    end

    def finalize!
      return if finalized?
      if organization.self_service?
        return false if stripe_invoice_id

        begin
          invoice_item = Stripe::InvoiceItem.create(customer: organization.stripe_customer_id,
                                                  amount: to_pence(grand_total),
                                                  currency: currency,
                                                  description: invoice_description)

          invoice = Stripe::Invoice.create(customer: organization.stripe_customer_id)
          update_attributes(stripe_invoice_id: invoice.id)
        rescue StandardError => e
          Honeybadger.notify(e)
          if invoice_item
            begin
              invoice_item.delete
            rescue StandardError => e
              Honeybadger.notify(e)
            end
          end

          if invoice
            invoice.delete
          end
        end
      end
      update_attributes(:finalized => true)
    end

    def period_start
      Time.parse("#{year}-#{month}-1").beginning_of_month
    end

    def period_end
      (Time.parse("#{year}-#{month}-1").end_of_month + 1.day).beginning_of_month
    end

    def net_total
      salesforce_object&.c2g__NetTotal__c || 0
    end

    def refresh_grand_total
      update_column(:grand_total, net_total)
    end

    def grand_total_plus_tax
      grand_total + (grand_total * (tax_percent.to_f / 100.0))
    end

    def salesforce_invoice_link
      salesforce_id.present? ? ExternalLinks.salesforce_invoice_path(salesforce_id) : ''
    end

    def stripe_invoice_link
      stripe_invoice_id.present? ? ExternalLinks.stripe_path(invoices, stripe_invoice_id) : ''
    end

    private

    def invoice_description
      discount_message = (discount_percent > 0) ? " (includes discount of #{discount_percent}%)" : ''
      "Cloud Usage #{Date::MONTHNAMES[month]} #{year}#{discount_message}. Invoice: #{salesforce_id})"
    end

    def currency
      'gbp'
    end

    def to_pence(amount_in_pounds)
      (amount_in_pounds * 100.0).ceil
    end

  end
end
