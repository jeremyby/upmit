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

  def is_owner?(obj)
    obj.user == current_user
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
