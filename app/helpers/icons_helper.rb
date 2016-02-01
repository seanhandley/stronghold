module IconsHelper
  def browser_icon(name)
    case name.downcase
    when 'chrome'
      tag('i', class: ['fa', 'fa-chrome'], style: 'color: #000')
    when 'firefox'
      tag('i', class: ['fa', 'fa-firefox'], style: 'color: #FF7700')
    when 'internet explorer'
      tag('i', class: ['fa', 'fa-edge'], style: 'color: #00AAFF')
    when 'safari'
      tag('i', class: ['fa', 'fa-safari'], style: 'color: #00AAFF')
    when 'opera'
      tag('i', class: ['fa', 'fa-opera'], style: 'color: #FF3300')
    else
      nil
    end
  end

  def os_icon(name)
    case name.downcase
    when 'windows'
      tag('i', class: ['fa', 'fa-windows'], style: 'color: #00AAFF')
    when 'linux', 'x11'
      tag('i', class: ['fa', 'fa-linux'], style: 'color: #000')
    when 'android'
      tag('i', class: ['fa', 'fa-android'], style: 'color: #44DD44')
    when 'macintosh', 'iphone', 'ipad'
      tag('i', class: ['fa', 'fa-apple'], style: 'color: #888')
    else
      nil
    end
  end
end