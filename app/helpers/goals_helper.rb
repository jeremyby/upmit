module GoalsHelper
  WEEKDAYS = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat']
  
  def weekday_checkbox(form, start_at = 0)
    i = start_at
    output = ''
    until i > (start_at + 6) do 
      output += "<label class='checkbox-inline'>#{ form.check_box :weekdays, { multiple: true }, i%7, nil} #{ WEEKDAYS[i%7] }</label>"
      i += 1
    end
    
    output.html_safe
  end
  
  def goal_interval(max)
    arr = []
    for i in 1..max
      arr << ["#{ i }", i]
    end
    
    options_for_select(arr, 1)
  end
  
  def get_days(lap)
    t = Time.now
    (((t + lap) - t) / 86400).to_i
  end
end
