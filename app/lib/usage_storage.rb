module UsageStorage
  def self.fetch(*args, &blk)
    args = args.first
    allowed_keys = [:year, :month, :organization_id]
    clause = args.slice(*allowed_keys)
    usage = Billing::Usage.where(clause).first
    usage = Billing::Usage.create(clause) unless usage
    
    unless usage.updated_at > Time.parse("#{usage.year}-#{usage.month}-01").end_of_month
      if args[:force] || usage.updated_at < 1.month.ago
        usage.update_attributes blob: yield, updated_at: Time.now
      end
    end

    usage.blob
  end
end
