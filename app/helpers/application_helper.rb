module ApplicationHelper
  def controller?(*controller)
      controller.include?(params[:controller])
    end

    def action?(*action)
      action.include?(params[:action])
    end
    
    def reset_tag(value)
      "<input type='reset' value='#{ value }' class='reset'>".html_safe
    end
end
