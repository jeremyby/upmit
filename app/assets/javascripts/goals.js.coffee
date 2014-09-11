
$(document).ready ->  
  upmit.now = new Date()
  upmit.currentSample = 0
  
  upmit.timeoutid = 0
  
  rotate_goal_samples() unless $('#goal_title').length && $('#goal_title').val().length
  
  update_frequency_title()
  
  
  $('#goal_title').on('focus', ->
    $(this).removeClass('error')
    clearTimeout(upmit.timeoutid)
  ).on('focusout', ->
    if $(this).val().length == 0
      rotate_goal_samples()
  )
  
  $('.frequency h3').on('click', (e) ->
    $('.frequency').toggleClass('active')
    $('.frequency .details').toggle('blind')
    $('.frequency h3 i').toggleClass('fa-rotate-180')
    
    update_frequency_day_inverval()
    update_frequency_week_times()
  ).on('mousedown', (e) ->
    e.preventDefault()
  )
  
  $('.duration h3').on('click', (e) ->
    $('.duration').toggleClass('active')
    $('.duration .details').toggle('blind')
    $('.duration h3 i').toggleClass('fa-rotate-180')
    
    if $('.duration').hasClass('active')
      $('#goal_duration').slider()
      
      update_slider($('#goal_duration').data('slider-value'))
      
      $('#goal_duration').on('slide', (slideEvt) ->
        update_slider_value(slideEvt.value)
      ).on('slideStop', (slideEvt) ->
        update_slider(slideEvt.value)
      )
    else
      setTimeout(->
        $('#goal_duration').slider('destroy')
      , 400)
  ).on('mousedown', (e) ->
    e.preventDefault()
  )
  
  $('.duration button').click (e) ->
    text = "for #{ $(this).data('value') } days"
    
    text = switch $(this).prop('id')
      when '3w' then "for 3 weeks"
      when '5w' then "for 5 weeks"
      when '10w' then "for 10 weeks"
      when '1m' then "for 1 month"
      when '3m' then "for 3 months"
      when '6m' then "for 6 months"
      when '1y' then "for 1 year"
    
    set_slider_button($(".duration button[data-value='#{ $(this).data('value') }']"))
    
    $('#goal_duration').slider('setValue', $(this).data('value'), true)
    
    $(".duration h3 span").text(text)
    
    e.preventDefault()
  
  # changing interval unit, day <-> week
  $('input[name="goal[interval_unit]"]').on('change', ->    
    update_frequency_title()
    show_end_date($('#goal_duration').data('sliderValue'))
  )
  
  # simply changing the day/days
  $('.frequency .day select').on('change', ->
    $('#goal_interval_unit_day').prop('checked', true)
    
    update_frequency_day_inverval()
    update_frequency_title()
  )
  
  # simply changing the weekly time/times
  $('.frequency .week select').on('change', ->
    $('#goal_interval_unit_week').prop('checked', true)
    
    update_frequency_week_times()
    
    w = $('.frequency label.checkbox-inline input:checked').length
    $('.frequency label.checkbox-inline input').prop('checked', false) unless w == $('.frequency .week select').val()
    
    update_frequency_title()
  )
  
  # clicking on weekday checkboxes
  $('.frequency label.checkbox-inline input:checkbox').on('change', ->
    $('#goal_interval_unit_week').prop('checked', true)
    
    w = $('.frequency label.checkbox-inline input:checked').length
    $('.frequency .week select').val(w)
    
    update_frequency_title()
  )
  
  # changing starting offset, day <-> week
  $('input[name="goal[starts]"]').on('change', ->
    show_end_date($('#goal_duration').data('sliderValue'))
  )
  
  $('.actions :submit').on('click', (e) ->
    if $('#goal_title').val().length == 0
      $('#goal_title').attr('placeholder', "need to describe the goal first...").addClass('error')
      clearTimeout(upmit.timeoutid)
      
      e.preventDefault()
  )

rotate_goal_samples = ->
  if upmit.timeoutid
    clearTimeout(upmit.timeoutid)
    
  upmit.timeoutid = setTimeout(rotater, 2500)

rotater = ->
  $('#goal_title').attr('placeholder', upmit.samples[upmit.currentSample++ % upmit.samples.length])
  rotate_goal_samples()

update_frequency_day_inverval = ->
  $('.frequency .day span').html(if $('.frequency .day select').val() > 1 then 'days' else 'day')
  
update_frequency_week_times = ->
  $('.frequency .week span').html(if $('.frequency .week select').val() > 1 then 'times' else 'time')
  

update_frequency_title = ->
  if $('input[name="goal[interval_unit]"]:checked').val() == 'day'
    d = $('.frequency .day select').val()
    
    if d > 1
      str = "every #{ d } days"
    else
      str = 'everyday'
      
    $('.starts label.left span').text('today').attr('title', '')
    $('.starts label.right span').text('tomorrow')
  else
    w = $('.frequency .week select').val()
    t = if w > 1 then 'times' else 'time'
    str = "#{ w } #{ t } a week"
    
    output = 'this week'
    output = '<i class="fa fa-exclamation"></i> ' + output if upmit.now.getDay() > 1
    
    $('.starts label.left span').html(output)
    
    if upmit.now.getDay() > 1
      $('.starts label.left')
      .attr('title', 'Days has passed in this week, are you sure you want to start your goal this week?')
      .data('toggle', "tooltip")
      .data('placement', "bottom")
      
      $('.starts label.left').tooltip()
    else
      $('.starts label.left').attr('title', '')
    
    $('.starts label.right span').text('next week')
    
  $('.frequency h3 span').html(str)

set_slider_button = (el) ->
  $('.duration button').removeClass('active')
  el.addClass('active')

update_slider = (value) ->
  update_slider_value(value)
  
  button = $(".duration button[data-value='#{ value }']")
  
  if button.length > 0
    set_slider_button(button)
  else
    $('.duration button').removeClass('active')

update_slider_value = (value) ->
  $(".duration h3 span").text("for #{ value } days")
  $('#goal_duration').data('sliderValue', value)
  show_end_date(value)

show_end_date = (value) ->
  if $('input[name="goal[interval_unit]"]:checked').val() == 'week'
    if $('input[name="goal[starts]"]:checked').val() == '1'
      value = value - upmit.now.getDay() + 7
    else
      value = value - upmit.now.getDay()
  else
    if $('input[name="goal[starts]"]:checked').val() == '1'
      value += 1      
    
  $('.duration .date').html('finishes on ' + upmit.now.addDays(value - 1).toLocaleDateString())
  