module HomeHelper
  def nav_link(link_type, link_text, link_path, link_icon)
    class_name = controller?(link_type) ? 'active' : nil
    output = ''
    
    content_tag(:li, class: class_name) do
      output += "<div class='pointer'><div class='arrow'></div><div class='arrow_border'></div></div>" if class_name == 'active'
      output += "<a href='#{ link_path }'><i class='fa #{ link_icon }'></i><span>#{ link_text }</span></a>"
      
      output.html_safe
    end
  end
  
  
  def get_fg_color(percentage)
    case percentage
    when 0..10
      "#50BB50"
    when 11..20
      "#72BB67"
    when 21..30
      "#93BB7E"
    when 31..40
      "#A7BB8D"
    when 41..50
      "BBB797"
    when 51..60
      "#BBAF8D"
    when 61..70
      "#BB987F"
    when 71..80
      "#BB5C5D"
    when 81..100
      "#BB2521"
    end
  end
end
