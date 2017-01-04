class FraudCheck; def suspicious?; ['Foo']; end; end

class MailerPreview < ActionMailer::Preview
  def signup
    Mailer.signup(Invite.first.id)
  end

  def usage_report
    from = (Time.now - 1.day).beginning_of_week
    to = (Time.now - 1.day).end_of_week
    data = Reports::UsageReport.new(from, to).contents
    Mailer.usage_report(from.to_s, to.to_s, data)
  end

  def usage_sanity_failures
    Mailer.usage_sanity_failures(Sanity.check)
  end

  def activation_reminder
    Mailer.activation_reminder('foo@bar.com')
  end

  def reset
    Mailer.reset(Reset.first.id)
  end

  def card_reverification_failure
    Mailer.card_reverification_failure(Organization.first)
  end

  def notify_wait_list_entry
    Mailer.notify_wait_list_entry('foo@bar.com')
  end

  def goodbye
    Mailer.goodbye(Organization.first.admin_users)
  end

  def notify_staff_of_signup
    Mailer.notify_staff_of_signup(CustomerSignup.first)
  end

  def fraud_check_alert
    Mailer.fraud_check_alert(CustomerSignup.last, fc)
  end

  def review_mode_alert
    Mailer.review_mode_alert(Organization.last)
  end

  def review_mode_successful
    Mailer.review_mode_successful(Organization.first)
  end

  def quota_changed
    Mailer.quota_changed(Organization.first)
  end

  def fc
    fc = Marshal::load "\x04\bo:\x0FFraudCheck\x06:\x15@customer_signupo:\x13CustomerSignup\x10:\x10@attributeso:\x1FActiveRecord::AttributeSet\x06;\bo:$ActiveRecord::LazyAttributeHash\n:\v@types}\x16I\"\aid\x06:\x06ETo:\x1FActiveModel::Type::Integer\t:\x0F@precision0:\v@scale0:\v@limiti\t:\v@rangeo:\nRange\b:\texclT:\nbeginl-\a\x00\x00\x00\x80:\bendl+\a\x00\x00\x00\x80I\"\tuuid\x06;\fTo:HActiveRecord::ConnectionAdapters::AbstractMysqlAdapter::MysqlString\b;\x0E0;\x0F0;\x10i\x01\xFFI\"\nemail\x06;\fT@\x10I\"\x16organization_name\x06;\fT@\x10I\"\x17stripe_customer_id\x06;\fT@\x10I\"\x0Fip_address\x06;\fT@\x10I\"\x0Fcreated_at\x06;\fTU:JActiveRecord::AttributeMethods::TimeZoneConversion::TimeZoneConverter[\t:\v__v2__[\x00[\x00o:!ActiveRecord::Type::DateTime\b;\x0Ei\x00;\x0F0;\x100I\"\x0Fupdated_at\x06;\fTU;\x17[\t;\x18[\x00[\x00@\x1AI\"\x12reminder_sent\x06;\fTo:\x1FActiveModel::Type::Boolean\b;\x0E0;\x0F0;\x100I\"\x12discount_code\x06;\fT@\x10I\"\freal_ip\x06;\fT@\x10I\"\x11forwarded_ip\x06;\fT@\x10I\"\x0Edevice_id\x06;\fT@\x10I\"\x18activation_attempts\x06;\fT@\vI\"\x0Fuser_agent\x06;\fT@\x10I\"\x14accept_language\x06;\fT@\x10I\"\x13retro_migrated\x06;\fT@!o:\x1DActiveModel::Type::Value\b;\x0E0;\x0F0;\x100:\f@values{\x16I\"\aid\x06;\fTi\x1FI\"\tuuid\x06;\fTI\"\ekSwazrXWQA6S8PvxiZKDTg\x06;\fTI\"\nemail\x06;\fTI\"*sean.handley+testvoucher203@gmail.com\x06;\fTI\"\x16organization_name\x06;\fT0I\"\x17stripe_customer_id\x06;\fTI\"\x17cus_90hxt5h7CXypDv\x06;\fTI\"\x0Fip_address\x06;\fTI\"\b::1\x06;\fTI\"\x0Fcreated_at\x06;\fTIu:\tTime\r\xE8\x1D\x1D\xC0\x00\x00\xB0q\x06:\tzoneI\"\bUTC\x06;\fFI\"\x0Fupdated_at\x06;\fTIu;\x1D\r\xE8\x1D\x1D\xC0\x00\x00\xB0\x87\x06;\x1EI\"\bUTC\x06;\fFI\"\x12reminder_sent\x06;\fTi\x00I\"\x12discount_code\x06;\fTI\"\x00\x06;\fTI\"\freal_ip\x06;\fT0I\"\x11forwarded_ip\x06;\fT0I\"\x0Edevice_id\x06;\fTI\"\eI80a3UwDnnOESCU-quf4iA\x06;\fTI\"\x18activation_attempts\x06;\fTi\x00I\"\x0Fuser_agent\x06;\fTI\"~Mozilla/5.0 (Macintosh; Intel Mac OS X 10_11_6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/52.0.2743.116 Safari/537.36\x06;\fTI\"\x14accept_language\x06;\fTI\"%en-US,en;q=0.8,fr;q=0.6,ru;q=0.4\x06;\fTI\"\x13retro_migrated\x06;\fT0:\x16@additional_types{\x00:\x12@materializedF:\x13@delegate_hash{\x16@\no:*ActiveRecord::Attribute::FromDatabase\n:\n@name@\n:\x1C@value_before_type_casti\x1F:\n@type@\v:\x18@original_attribute0:\v@valuei\x1F@\x0Fo;\"\n;\#@\x0F;$@.;%@\x10;&0;'I\"\ekSwazrXWQA6S8PvxiZKDTg\x06;\fT@\x11o;\"\n;\#@\x11;$@0;%@\x10;&0;'I\"*sean.handley+testvoucher203@gmail.com\x06;\fT@\x12o;\"\n;\#@\x12;$0;%@\x10;&0;'0@\x13o;\"\n;\#@\x13;$@3;%@\x10;&0;'I\"\x17cus_90hxt5h7CXypDv\x06;\fT@\x14o;\"\n;\#@\x14;$@5;%@\x10;&0;'I\"\b::1\x06;\fT@\x15o;\"\n;\#@\x15;$@8;%@\x16;&0;'U: ActiveSupport::TimeWithZone[\bIu;\x1D\r\xE8\x1D\x1D\xC0\x00\x00\xB0q\x06;\x1EI\"\bUTC\x06;\fFI\"\vLondon\x06;\fTu;\x1D\r\xE9\x1D\x1D\xC0\x00\x00\xB0q@\eo;\"\n;\#@\e;$@;;%@\x1C;&0;'U;([\bIu;\x1D\r\xE8\x1D\x1D\xC0\x00\x00\xB0\x87\x06;\x1EI\"\bUTC\x06;\fF@Zu;\x1D\r\xE9\x1D\x1D\xC0\x00\x00\xB0\x87@ o;\"\n;\#@ ;$i\x00;%@!;&0;'F@\"o;\"\n;\#@\";$@>;%@\x10;&0;'I\"\x00\x06;\fT@#o;\"\n;\#@#;$0;%@\x10;&0;'0@$o;\"\n;\#@$;$0;%@\x10;&0;'0@%o;\"\n;\#@%;$@B;%@\x10;&0;'I\"\eI80a3UwDnnOESCU-quf4iA\x06;\fT@&o;\"\n;\#@&;$i\x00;%@\v;&0;'i\x00@'o;\"\n;\#@';$@E;%@\x10;&0;'I\"~Mozilla/5.0 (Macintosh; Intel Mac OS X 10_11_6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/52.0.2743.116 Safari/537.36\x06;\fT@(o;\"\n;\#@(;$@G;%@\x10;&0;'I\"%en-US,en;q=0.8,fr;q=0.6,ru;q=0.4\x06;\fT@)o;\"\n;\#@);$0;%@!;&0;'0:\x17@aggregation_cache{\x00:\x17@association_cache{\x00:\x0E@readonlyF:\x0F@destroyedF:\x1C@marked_for_destructionF:\x1E@destroyed_by_association0:\x10@new_recordF:\t@txn0:\x1E@_start_transaction_state{\x00:\x17@transaction_state0"
    fc.define_singleton_method :response_fields do
      {:distance=>0, :country_match=>nil, :country_code=>"SE", :free_mail=>true, :anonymous_proxy=>false, :bin_match=>"NA", :bin_country=>nil, :error=>"CITY_REQUIRED", :proxy_score=>1.8, :ip_region=>nil, :ip_city=>nil, :ip_latitude=>59.3247, :ip_longitude=>18.056, :bin_name=>nil, :ip_isp=>"Inter Connects Inc", :ip_org=>"Reverse-Proxy", :bin_name_match=>"NA", :bin_phone_match=>"NA", :bin_phone=>nil, :phone_in_billing_location=>nil, :high_risk_country=>false, :queries_remaining=>1022, :city_postal_match=>nil, :ship_city_postal_match=>nil, :maxmind_id=>"NIQEF0PF", :ip_asnum=>"AS57858 Inter Connects Inc", :ip_user_type=>"hosting", :ip_country_conf=>99, :ip_region_conf=>nil, :ip_city_conf=>nil, :ip_postal_code=>nil, :ip_postal_conf=>nil, :ip_accuracy_radius=>100, :ip_net_speed_cell=>nil, :ip_metro_code=>0, :ip_area_code=>0, :ip_time_zone=>"Europe/Stockholm", :ip_region_name=>nil, :ip_domain=>nil, :ip_country_name=>"Sweden", :ip_continent_code=>"EU", :ip_corporate_proxy=>false, :is_transparent_proxy=>false, :high_risk_email=>false, :ship_forward=>"NA", :risk_score=>89.29, :prepaid=>nil, :minfraud_version=>1.3, :service_level=>"standard"}
    end
    fc.define_singleton_method :request_fields do
      {:client_ip=>"5.34.243.243", :forwarded_ip=>"5.34.243.243", :email=>"gerthaqalecompte@yahoo.com", :user_agent=>"Opera/9.80 (Windows NT 6.2; Win64; x64) Presto/2.12.388 Version/12.17", :accept_language=>"en-US,en;q=0.5", :city=>nil, :postal=>nil, :country=>nil, :shipping_address=>"\n", :shipping_city=>nil, :shipping_postal=>nil, :shipping_country=>nil}
    end
    fc.define_singleton_method :suspicious? do
      ["Risk score greater than five"]
    end
    fc.define_singleton_method :card_fields do
      {}
    end
    fc
  end

  def quota_limits_alert
    Mailer.quota_limits_alert(Organization.first)
  end
end
