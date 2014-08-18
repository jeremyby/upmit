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
    image_tag asset_path("/assets/legends/#{g.legend}.png")
  end
  
  def label_maker(type, text, title = nil)
    content_tag(:span, text, class: "label label-#{type}", title: title)
  end
  
  def expiring_label(str)
    label_maker('danger', str, title: 'Not checked in yet and expiring today.')
  end
  
  def checkin_btn_group(commit, type)
    content_tag 'div', (link_to (content_tag 'i', '', class: 'fa fa-check fa-lg') + 'Yes', commit_check_path(commit, type: type), class: 'yes btn btn-default', method: :post, remote: true) +
      (link_to 'No', commit_fail_path(commit, type: type), class: 'no btn btn-default', method: :post, remote: true), class: 'check_in btn-group'
  end
  
  def describe_daily_last_occur(goal, arr)
    commit = arr.first
    
    date_in_number = commit.starts_at.in_time_zone(goal.timezone).strftime("%b %d")
    date = Time.now.in_time_zone(goal.timezone).beginning_of_day.utc - commit.starts_at > 24.hours ? date_in_number : 'Yesteday'
    
    if commit.active?
      expiring_label(date) + "Did you #{ h goal.title } #{ date.downcase }?" + checkin_btn_group(commit, 'last')
    else
      if commit.succeed?
        label_maker('success', date) + content_tag('i', '', class: 'fa fa-check fa-lg')
      else
        label_maker('default', date) + content_tag('i', '', class: 'fa fa-times fa-lg')
      end
    end
  end
  
  def describe_daily_today_occur(goal, arr)
    commit = arr.first
  
    case
    when commit.active?
      label_maker('primary', 'Today') + "Did you #{ h goal.title }?" + checkin_btn_group(commit, 'today')
    when commit.succeed?
      label_maker('success', 'Today') + "You've checked in, and earned one dollar back."
    when commit.failed?
      label_maker('default', 'Today') + "You did not #{ h goal.title }. Let us pick it up the next time."
    end
  end
  
  def describe_weekday_last_occur(goal, arr)
    commit = arr.first
    
    wday = commit.starts_at.in_time_zone(goal.timezone).strftime("%a")
    
    if commit.active?
      expiring_label(wday) + "Did you #{ h goal.title } on #{ wday }?" + checkin_btn_group(commit, 'last')
    else
      if commit.succeed?
        label_maker('success', wday) + content_tag('i', '', class: 'fa fa-check fa-large')
      else
        label_maker('default', wday) + content_tag('i', '', class: 'fa fa-times fa-large')
      end
    end
  end

  
  def describe_weektime_last_occur(goal, arr)
    active = arr.to_ary.select {|c| c.active?}
    
    if active.size > 0
      succeed =  arr.to_ary.select {|c| c.succeed?}
      failed =  arr.to_ary.select {|c| c.failed?}
      
      str = expiring_label('Last week')
      
      unless active.size == arr.size
        str += (succeed.blank? ? '' : "#{ pluralize succeed.size, 'hit' }, ") + (failed.blank? ? '' : "#{ pluralize failed.size, 'miss' }, ") + "and #{ active.size } to go. "
      end
      
      str += "Did you #{ h goal.title } last week?"
      
      return str + checkin_btn_group(active.first, 'last')
    end
  end
  
  def describe_weektime_today_occur(goal, arr)
    succeed =  arr.to_ary.select {|c| c.succeed?}
    active = arr.to_ary.select {|c| c.active?}
    failed =  arr.to_ary.select {|c| c.failed?}
    
    case
    when succeed.size == arr.size # all succeed
      label_maker('success', 'This week') + "You've made it last week, and earned #{ pluralize goal.weektimes, 'dollar' } back."
        
    when failed.size == arr.size # all failed
      label_maker('default', 'This week') + "You failed to #{ h goal.title } this week."
    
    when active.size == arr.size
      label_maker('primary', 'This week') + "Did you #{ h goal.title }?" + checkin_btn_group(active.first, 'today')
    
    else
      if active.size > 0
        str = label_maker('primary', 'This week')
        
        str += (succeed.blank? ? '' : "#{ pluralize succeed.size, 'hit' }, ") + (failed.blank? ? '' : "#{ pluralize failed.size, 'miss' }, ") + "and #{ active.size } to go. " +
          "Did you #{ h goal.title }?"
        
        return str + checkin_btn_group(active.first, 'today') 
      else
        return label_maker('warning', 'This week') + "#{ pluralize succeed.size, 'hit' } and #{ pluralize failed.size, 'miss' }."
      end
    end
  end
end
