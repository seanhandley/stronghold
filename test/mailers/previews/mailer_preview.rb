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
    fc = Marshal::load("\x04\bo:\x0FFraudCheck\x06:\x15@customer_signupo:\x13CustomerSignup\x11:\x10@attributeso:\x1FActiveRecord::AttributeSet\x06;\bo:$ActiveRecord::LazyAttributeHash\n:\v@types}\x16I\"\aid\x06:\x06ETo: ActiveRecord::Type::Integer\t:\x0F@precision0:\v@scale0:\v@limiti\t:\v@rangeo:\nRange\b:\texclT:\nbeginl-\a\x00\x00\x00\x80:\bendl+\a\x00\x00\x00\x80I\"\tuuid\x06;\fTo:HActiveRecord::ConnectionAdapters::AbstractMysqlAdapter::MysqlString\b;\x0E0;\x0F0;\x10i\x01\xFFI\"\nemail\x06;\fT@\x10I\"\x16organization_name\x06;\fT@\x10I\"\x17stripe_customer_id\x06;\fT@\x10I\"\x0Fip_address\x06;\fT@\x10I\"\x0Fcreated_at\x06;\fTU:JActiveRecord::AttributeMethods::TimeZoneConversion::TimeZoneConverter[\t:\v__v2__[\x00[\x00o:JActiveRecord::ConnectionAdapters::AbstractMysqlAdapter::MysqlDateTime\b;\x0E0;\x0F0;\x100I\"\x0Fupdated_at\x06;\fTU;\x17[\t;\x18[\x00[\x00@\x1AI\"\x12reminder_sent\x06;\fTo: ActiveRecord::Type::Boolean\b;\x0E0;\x0F0;\x10i\x06I\"\x12discount_code\x06;\fT@\x10I\"\freal_ip\x06;\fT@\x10I\"\x11forwarded_ip\x06;\fT@\x10I\"\x0Edevice_id\x06;\fT@\x10I\"\x18activation_attempts\x06;\fT@\vI\"\x0Fuser_agent\x06;\fT@\x10I\"\x14accept_language\x06;\fT@\x10I\"\x13retro_migrated\x06;\fT@!o:\x1EActiveRecord::Type::Value\b;\x0E0;\x0F0;\x100:\f@values{\x16I\"\aid\x06;\fTi\x02\xBF\x02I\"\tuuid\x06;\fTI\"\eoD8-ijBkiPEXL0z2SBfj3A\x06;\fTI\"\nemail\x06;\fTI\"\x1Ewayne.wang@spirentcom.com\x06;\fTI\"\x16organization_name\x06;\fT0I\"\x17stripe_customer_id\x06;\fTI\"\x17cus_8fqt7QTnv9z9mS\x06;\fTI\"\x0Fip_address\x06;\fTI\"\x14198.199.102.235\x06;\fTI\"\x0Fcreated_at\x06;\fTIu:\tTime\r\x90\x16\x1D\xC0\x00\x00@Q\x06:\tzoneI\"\bUTC\x06;\fFI\"\x0Fupdated_at\x06;\fTIu;\x1D\r\x91\x16\x1D\xC0\x00\x00\xF0\x9C\x06;\x1EI\"\bUTC\x06;\fFI\"\x12reminder_sent\x06;\fTi\x06I\"\x12discount_code\x06;\fTI\"\x00\x06;\fTI\"\freal_ip\x06;\fTI\"\x14198.199.102.235\x06;\fTI\"\x11forwarded_ip\x06;\fTI\"\x14198.199.102.235\x06;\fTI\"\x0Edevice_id\x06;\fTI\"\e7sMY65Iqw4UqzRN9AYJWKQ\x06;\fTI\"\x18activation_attempts\x06;\fTi\x00I\"\x0Fuser_agent\x06;\fTI\"qMozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/51.0.2704.84 Safari/537.36\x06;\fTI\"\x14accept_language\x06;\fTI\"\x1Czh-CN,zh;q=0.8,en;q=0.6\x06;\fTI\"\x13retro_migrated\x06;\fT0:\x16@additional_types{\x00:\x12@materializedF:\x13@delegate_hash{\x16@\no:*ActiveRecord::Attribute::FromDatabase\t:\n@name@\n:\x1C@value_before_type_casti\x02\xBF\x02:\n@type@\v:\v@valuei\x02\xBF\x02@\x0Fo;\"\t;\#@\x0F;$@.;%@\x10;&I\"\eoD8-ijBkiPEXL0z2SBfj3A\x06;\fT@\x11o;\"\t;\#@\x11;$@0;%@\x10;&I\"\x1Ewayne.wang@spirentcom.com\x06;\fT@\x12o;\"\t;\#@\x12;$0;%@\x10;&0@\x13o;\"\t;\#@\x13;$@3;%@\x10;&I\"\x17cus_8fqt7QTnv9z9mS\x06;\fT@\x14o;\"\t;\#@\x14;$@5;%@\x10;&I\"\x14198.199.102.235\x06;\fT@\x15o;\"\t;\#@\x15;$@8;%@\x16;&U: ActiveSupport::TimeWithZone[\b@8I\"\vLondon\x06;\fTu;\x1D\r\x91\x16\x1D\xC0\x00\x00@Q@\eo;\"\t;\#@\e;$@;;%@\x1C;&U;'[\b@;@Zu;\x1D\r\x92\x16\x1D\xC0\x00\x00\xF0\x9C@ o;\"\t;\#@ ;$i\x06;%@!;&T@\"o;\"\t;\#@\";$@>;%@\x10;&I\"\x00\x06;\fT@#o;\"\t;\#@#;$@@;%@\x10;&I\"\x14198.199.102.235\x06;\fT@$o;\"\t;\#@$;$@B;%@\x10;&I\"\x14198.199.102.235\x06;\fT@%o;\"\t;\#@%;$@D;%@\x10;&I\"\e7sMY65Iqw4UqzRN9AYJWKQ\x06;\fT@&o;\"\t;\#@&;$i\x00;%@\v;&i\x00@'o;\"\t;\#@';$@G;%@\x10;&I\"qMozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/51.0.2704.84 Safari/537.36\x06;\fT@(o;\"\t;\#@(;$@I;%@\x10;&I\"\x1Czh-CN,zh;q=0.8,en;q=0.6\x06;\fT@)o;\"\t;\#@);$0;%@!;&0:\x17@aggregation_cache{\x00:\x17@association_cache{\x00:\x0E@readonlyF:\x0F@destroyedF:\x1C@marked_for_destructionF:\x1E@destroyed_by_association0:\x10@new_recordF:\t@txn0:\x1E@_start_transaction_state{\x00:\x17@transaction_state0:\x15@stripe_customeru:\x15Stripe::Customer\x02v\x06\x04\b[\a{\x15:\aidI\"\x17cus_8fqt7QTnv9z9mS\x06:\x06ET:\vobjectI\"\rcustomer\x06;\x06T:\x14account_balancei\x00:\x14business_vat_id0:\fcreatedl+\a\x95\x18hW:\rcurrency0:\x13default_sourceI\"\"card_18OVBdAR2MipIX2iUXLTziJJ\x06;\x06T:\x0FdelinquentF:\x10descriptionI\"LCompany: wayne.wang@spirentcom.com, Signup UUID: oD8-ijBkiPEXL0z2SBfj3A\x06;\x06T:\rdiscount0:\nemailI\"\x1Ewayne.wang@spirentcom.com\x06;\x06T:\rlivemodeT:\rmetadatau:\x19Stripe::StripeObject>\x04\b[\a{\x00{\x06:\fapi_keyI\"%sk_live_0RdYtPMxUo5x8GKURnBayo63\x06:\x06ET:\rshipping0:\fsourcesu:\x17Stripe::ListObject\x02\xAD\x03\x04\b[\a{\n:\vobjectI\"\tlist\x06:\x06ET:\tdata[\x06u:\x11Stripe::Card\x02\xF9\x02\x04\b[\a{\x1C:\aidI\"\"card_18OVBdAR2MipIX2iUXLTziJJ\x06:\x06ET:\vobjectI\"\tcard\x06;\x06T:\x11address_cityI\"\fBeijing\x06;\x06T:\x14address_countryI\"\aCN\x06;\x06T:\x12address_line1I\"$Shining Tower, Haidian district\x06;\x06T:\x18address_line1_checkI\"\x10unavailable\x06;\x06T:\x12address_line2I\"\fBeijing\x06;\x06T:\x12address_state0:\x10address_zipI\"\v100891\x06;\x06T:\x16address_zip_checkI\"\x10unavailable\x06;\x06T:\nbrandI\"\tVisa\x06;\x06T:\fcountryI\"\aCN\x06;\x06T:\rcustomerI\"\x17cus_8fqt7QTnv9z9mS\x06;\x06T:\x0Ecvc_checkI\"\tpass\x06;\x06T:\x12dynamic_last40:\x0Eexp_monthi\n:\rexp_yeari\x02\xE3\a:\x10fingerprintI\"\x15xYR3v5nPQriRioRA\x06;\x06T:\ffundingI\"\vcredit\x06;\x06T:\nlast4I\"\t8130\x06;\x06T:\rmetadatau:\x19Stripe::StripeObjectk\x04\b[\a{\x06:\x12last_verifiedI\"\x1C2016-06-20 16:24:00 UTC\x06:\x06ET{\x06:\fapi_keyI\"%sk_live_0RdYtPMxUo5x8GKURnBayo63\x06;\x06T:\tnameI\"\rwang yan\x06;\x06T:\x18tokenization_method0{\x06:\fapi_keyI\"%sk_live_0RdYtPMxUo5x8GKURnBayo63\x06;\x06T:\rhas_moreF:\x10total_counti\x06:\burlI\"-/v1/customers/cus_8fqt7QTnv9z9mS/sources\x06;\x06T{\x06:\fapi_keyI\"%sk_live_0RdYtPMxUo5x8GKURnBayo63\x06;\x06T:\x12subscriptionsu;\x16\x01\xA8\x04\b[\a{\n:\vobjectI\"\tlist\x06:\x06ET:\tdata[\x00:\rhas_moreF:\x10total_counti\x00:\burlI\"3/v1/customers/cus_8fqt7QTnv9z9mS/subscriptions\x06;\x06T{\x06:\fapi_keyI\"%sk_live_0RdYtPMxUo5x8GKURnBayo63\x06;\x06T{\x06:\fapi_keyI\"%sk_live_0RdYtPMxUo5x8GKURnBayo63\x06;\x06T")
  end

  def quota_limits_alert
    Mailer.quota_limits_alert(Organization.first)
  end
end
