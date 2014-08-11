module AuditsHelper
  def audit_detail(audit)
    details = ''
    if audit.action == 'update'
      details = audit.audited_changes.collect do |k,v|
        "#{t(k.underscore.to_sym).capitalize.humanize} #{t(:is_now)} '#{r(v[1])}' (#{t(:used_to_be)} '#{r(v[0])}')"
      end.join '. '
    else
      details = audit.audited_changes.collect do |k,v|
        "'#{t(k.underscore.to_sym).capitalize.humanize}': '#{r(v)}'"
      end.join ', '
    end
    details += '.'
  end

  def audit_colour(audit)
    case audit.action
    when 'create'
      'text-success'
    when 'destroy'
      'text-danger'
    when 'start'
      'text-success'
    when 'stop'
      'text-danger'
    else
      'text-info'
    end
      
  end
end