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
  
  def label_maker(text, type = 'default', title = nil)
    content_tag(:span, text, class: "label label-#{type}", title: title)
  end
  
  def expiring_label(str)
    label_maker(str, 'warning', 'Not checked in yet and expiring today.')
  end
  
  def check_icon
    content_tag('i', '', class: 'fa fa-check fa-lg')
  end
  
  def cross_icon
    content_tag('i', '', class: 'fa fa-times fa-lg')
  end
  
  def checkin_btn_group(commit, type)
    "<div class='check_in btn-group'>
      <a class='yes btn btn-default' data-method='post' data-remote='true' href='#{ commit_check_path(commit, type: type)}' rel='nofollow'><i class='fa fa-check fa-lg'></i>Yes</a>
      <a class='no btn btn-default' data-method='post' data-remote='true' href='#{ commit_fail_path(commit, type: type)}' rel='nofollow'>No</a>
    </div>".html_safe
  end
  
  def describe_daily_last_occur(goal, arr)
    commit = arr.first
    
    date_in_number = commit.starts_at.in_time_zone(goal.user.timezone).strftime("%b %d")
    date = Time.now.in_time_zone(goal.user.timezone).beginning_of_day.utc - commit.starts_at > 24.hours ? date_in_number : 'Yesteday'
    
    case
    when commit.active?
      expiring_label(date) + "Did you #{ h goal.title } #{ date.downcase }?" + checkin_btn_group(commit, 'last')
    when commit.succeed?
      label_maker(date) + check_icon
    when commit.failed?
      label_maker(date) + cross_icon
    end
  end
  
  def describe_daily_today_occur(goal, arr)
    commit = arr.first
    
    case
    when commit.active?
       label_maker('Today', 'primary') + "Did you #{ h goal.title }? #{}" + checkin_btn_group(commit, 'today')
    when commit.succeed?
      label_maker('Today') + check_icon
    when commit.failed?
      label_maker('Today') + cross_icon
    end
  end
  
  def describe_weekday_last_occur(goal, arr)
    commit = arr.first
    
    wday = commit.starts_at.in_time_zone(goal.user.timezone).strftime("%A")
    
    case
    when commit.active?
      expiring_label(wday) + "Did you #{ h goal.title } on #{ wday }?" + checkin_btn_group(commit, 'last')
    when commit.succeed?
      label_maker(wday) + check_icon
    when commit.failed?
      label_maker(wday) + cross_icon
    end
  end

  
  def describe_weektime_last_occur(goal, arr)
    active = arr.to_ary.select {|c| c.active?}
    
    last_label = active.size > 0 ? expiring_label('Last week') : label_maker('Last week')
    
    icons = ''
    
    arr.each do |c|
      icons << check_icon if c.succeed?
      icons << cross_icon if c.failed?
    end
    
    actions = ''
    
    if active.size > 0 
      actions << "Did you #{ h goal.title } last week?"
      actions << checkin_btn_group(active.first, 'last')
    end

    last_label + icons.html_safe + actions.html_safe
  end
  
  def describe_weektime_today_occur(goal, arr)
    active = arr.to_ary.select {|c| c.active?}
    
    today_label = active.size > 0 ? label_maker('This week', 'primary') : label_maker('This week')
    
    str = ''
    
    arr.each do |c|
      str << check_icon if c.succeed?
      str << cross_icon if c.failed?
    end
    
    actions = ''
    
    if active.size > 0 
      actions << "Did you #{ h goal.title }?"
      actions << checkin_btn_group(active.first, 'today')
    end

    today_label + str.html_safe + actions.html_safe
  end
end
