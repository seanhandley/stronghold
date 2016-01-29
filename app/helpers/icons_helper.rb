module IconsHelper
  def browser_icon(name)
    case name.downcase
    when 'chrome'
      tag('i', class: ['fa', 'fa-chrome'])
    when 'firefox'
      tag('i', class: ['fa', 'fa-firefox'])
    when 'internet explorer'
      tag('i', class: ['fa', 'fa-edge'])
    when 'safari'
      tag('i', class: ['fa', 'fa-safari'])
    else
      nil
    end
  end

  def os_icon(name)
    case name.downcase
    when 'windows'
      tag('i', class: ['fa', 'fa-windows'])
    when 'linux', 'x11'
      tag('i', class: ['fa', 'fa-linux'])
    when 'macintosh'
      tag('i', class: ['fa', 'fa-apple'])
    else
      nil
    end
  end
end