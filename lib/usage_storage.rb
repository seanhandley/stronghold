module UsageStorage
  def self.fetch(*args, &blk)
    usage = Billing::Usage.where(*args).first
    usage = Billing::Usage.create(*args) unless usage
    
    unless usage.updated_at > Time.parse("#{usage.year}-#{usage.month}-01").end_of_month
      if args[:force]
        usage.update_attributes blob: yield, updated_at: Time.now
      end
    end

    usage.blob
  end
end
