module UsageStorage
  def self.fetch(*args, &blk)
    force = args.delete(:force)
    allowed_keys = [:year, :month, :organization_id]
    usage = Billing::Usage.where(*(args.slice(allowed_keys))).first
    usage = Billing::Usage.create(*(args.slice(allowed_keys))) unless usage
    
    unless usage.updated_at > Time.parse("#{usage.year}-#{usage.month}-01").end_of_month
      if force
        usage.update_attributes blob: yield, updated_at: Time.now
      end
    end

    usage.blob
  end
end
