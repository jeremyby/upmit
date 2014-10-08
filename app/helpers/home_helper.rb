module HomeHelper
  def nav_link(condition, link_text, link_path, link_icon)
    class_name = condition ? 'active' : nil
    output = ''
    
    content_tag(:li, class: class_name) do
      output += "<div class='pointer'><div class='arrow'></div><div class='arrow_border'></div></div>" if class_name == 'active'
      output += "<a href='#{ link_path }'><i class='fa #{ link_icon }'></i><span>#{ link_text }</span></a>"
      
      output.html_safe
    end
  end
end
