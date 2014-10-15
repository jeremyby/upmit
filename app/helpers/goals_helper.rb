module GoalsHelper
  def weekday_checkbox(form, start_at = 0)
    i = start_at
    output = ''
    until i > (start_at + 6) do 
      output += "<label class='checkbox-inline'>#{ form.check_box :weekdays, { multiple: true }, i%7, nil} #{ Goal::WEEKDAYS[i%7] }</label>"
      i += 1
    end
    
    output.html_safe
  end
  
  def goal_interval(max, selected)
    arr = []
    for i in 1..max
      arr << ["#{ i }", i]
    end
    
    options_for_select(arr, selected)
  end
  
  def get_days(lap)
    t = Time.now
    (((t + lap) - t) / 86400).to_i
  end
  
  def get_goal_legend(g)
    image_tag asset_path("legends/#{g.legend}.png")
  end
  
  def label_maker(text, type = 'default', title = nil)
    content_tag(:span, text, class: "label label-#{type}", title: title)
  end
  
  def expiring_label(str)
    label_maker(str, 'warning', 'Not checked in yet and expiring today.')
  end
  
  def check_icon
    content_tag('i', '', class: 'fa fa-check-circle-o fa-lg')
  end
  
  def cross_icon
    content_tag('i', '', class: 'fa fa-times-circle-o fa-lg')
  end
  
  def fa_icon(str)
    content_tag('i', '', class: "fa #{ str }")
  end
  
  
  def describe_daily_last_occur(goal, arr)
    commit = arr.first
    
    fa_icon('fa-chevron-left') + ' Yesteday' + (commit.succeed? ? fa_icon('fa-check-circle') : fa_icon('fa-times-circle'))
  end
  
  def describe_daily_today_occur(goal, arr)
    commit = arr.first
    
    str = fa_icon('fa-circle') + 'Today'
    
    case
    when commit.active?
       label_maker(str, 'info') + "Did you #{ h goal.title }?"
    when commit.succeed?
      label_maker(str) + check_icon
    when commit.failed?
      label_maker(str) + cross_icon
    end
  end
  
  def describe_daily_next_occur(goal, arr)
    'Tomorrow'
  end
  
  def describe_weekday_last_occur(goal, arr)
    commit = arr.first
    
    wday = commit.starts_at.in_time_zone(goal.timezone).strftime("%A")
    
    fa_icon('fa-chevron-left') + ' ' + wday + (commit.succeed? ? fa_icon('fa-check-circle') : fa_icon('fa-times-circle'))
  end
  
  def describe_weekday_next_occur(goal, arr)
    commit = arr.first
    
    wday = commit.starts_at.in_time_zone(goal.timezone).strftime("%A")
    
    return wday
  end
  
  def describe_weektime_last_occur(goal, arr)
    icons = fa_icon('fa-chevron-left') + ' Last week'
    
    arr.each do |c|
      icons << (c.succeed? ? fa_icon('fa-check-circle') : fa_icon('fa-times-circle'))
    end

    return icons
  end
  
  def describe_weektime_today_occur(goal, arr)
    active = arr.to_ary.select {|c| c.active?}
    
    this_week = content_tag('i', '', class: 'fa fa-circle') + 'This week'
    today_label = active.size > 0 ? label_maker(this_week, 'info') : label_maker(this_week)
    
    str =  ''
    
    arr.each do |c|
      str << check_icon if c.succeed?
      str << cross_icon if c.failed?
    end
    
    actions = ''
    
    if active.size > 0 
      actions << "Did you #{ h goal.title }?  "
    end

    today_label + str.html_safe + actions.html_safe
  end
  
  def describe_weektime_next_occur(goal, arr)
    'Next week'
  end
end
