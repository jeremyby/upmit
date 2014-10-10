
$(document).ready ->  
  upmit.now = new Date()
  upmit.currentSample = 0
  
  upmit.timeoutid = 0
  
  $.fn.editable.defaults.mode = 'inline'
  $.fn.editable.defaults.ajaxOptions = {type: "PUT"}
  
  rotate_goal_samples() unless $('#goal_title').length && $('#goal_title').val().length
  
  update_frequency_title()


  # 
  # Show Goal
  #
  
  $('.legend .edit').click (e) ->
    $(document).bind('keyup', esc_close_legends)
    
    $('.legends').show('fold').focus()
    e.stopPropagation()
  
  $('.legends').blur (e) ->
    $('.legends').hide('fold')
    e.stopPropagation()
    
  $(".legends a").click ->
    upmit.start_spinner()
    
    $(".legends a").removeClass('clicked')
    $(this).addClass('clicked')
    
  $(".legends a").bind("ajax:success", (e) ->
    $('.goal #goal-legend img').attr('src', $(".legends a.clicked").data('url'))
    
    upmit.stop_spinner()
    $('.legends').hide('fold')
    
    upmit.message('The legend was updated successfully.', 'notice')
  )
  
  
  $('.goal-wrapper .attrs .hash-tag.active .editable').editable({
    container: 'body'
    mode: 'popup'
    placement: 'right'
  })
  
  $('.goal-wrapper .attrs .visibility.active .editable').editable({
    container: 'body'
    mode: 'popup'
    placement: 'right'
  })
  
  
  $('.goal h3 .editable').editable({
    toggle: 'manual',
    onblur: 'ignore',
    inputclass: 'edit-title',
    validate: (value) ->
      return "Goal's title cannot be empty" if($.trim(value) == '')
  })
  
  $('.goal h3 .editable').on('hidden', ->
    $('.goal-wrapper .goal h3 .edit').show()
  )
  
  $('.goal .desc .new.editable').editable({
    toggle: 'manual'
    onblur: 'ignore'
    inputclass: 'edit-desc'
    emptytext: ''
  })
  

  
  $('.goal .desc .exist.editable').editable({
    toggle: 'manual',
    onblur: 'ignore',
    inputclass: 'edit-desc',
    emptytext: 'The description is removed.',
    escape: false,
    rows: 5
  })
  
  $('.goal-wrapper .goal h3 .edit-title a').click (e) ->
    e.stopPropagation()
    
    $('.goal-wrapper .goal h3 .editable').editable('toggle')
    $('.goal-wrapper .goal h3 .edit').hide()
    
  $('.goal-wrapper .goal .attrs .desc a').click (e) ->
    e.stopPropagation()

    $('.goal .desc .new.editable').editable('toggle')
    $('.goal .desc .edit-desc').autosize()
    

  $('.goal-wrapper .goal .desc .edit-desc a').click (e) ->
    e.stopPropagation()

    $('.goal .desc .exist.editable').editable('toggle')
    $('.goal .desc .edit-desc').autosize()
  

  esc_close_legends = (e) ->
    if (e.keyCode == 27)
      $('.legends').hide('fold')
      $(document).unbind('keyup', esc_close_legends)
    
    return false
  
      
  update_activities = (e, data, status, xhr) ->
    if data.status == 200
      upmit.debug = data.responseText
      div = $("<div style='display: none'></div>")
      div.html(data.responseText)
      
      $('.activities .more').replaceWith(div)
      div.slideDown(2000, ->
        upmit.stop_spinner()
      )
      
  
  $(document).on("ajax:complete", '.activities .more a', update_activities)
  
  $(document).on('ajax:beforeSend', '.activities .more a', ->
    upmit.start_spinner()
  )
  
  upmit.click_commit_edit = (e) ->
    e.preventDefault()
    
    $('#edit-commit form').attr('action', '/commits/' + $(this).closest('.activity').data('id'))
    $('#edit-commit .modal-body #note').val($(this).closest('.activeable').find('.body').html())
    
    $('#edit-commit form input[type="file"], #edit-commit form input[type="text"]').attr('placeholder', 'Not changed')
    
    $('#edit-commit').modal()

  $('.activities .activity .edit a').on('click', upmit.click_commit_edit)
  

  $('.activities .activeable a.delete').on('ajax:success', ->
    $(this).closest('.activity').fadeOut('fast', ->
      $(this).remove()
    )
  )
  
  # 
  # New Goal
  # 
  $('.new-goal-wrapper #goal_title').on('focus', ->
    $(this).removeClass('error')
    clearTimeout(upmit.timeoutid)
  ).on('focusout', ->
    if $(this).val().length == 0
      rotate_goal_samples()
  )
  
  $('.new-goal-wrapper .frequency h3').on('click', (e) ->
    $('.new-goal-wrapper .frequency').toggleClass('active')
    $('.new-goal-wrapper .frequency .details').toggle('blind')
    $('.new-goal-wrapper .frequency h3 i').toggleClass('fa-rotate-180')
    
    update_frequency_day_inverval()
    update_frequency_week_times()
  ).on('mousedown', (e) ->
    e.preventDefault()
  )
  
  $('.new-goal-wrapper .duration h3').on('click', (e) ->
    $('.new-goal-wrapper .duration').toggleClass('active')
    $('.new-goal-wrapper .duration .details').toggle('blind')
    $('.new-goal-wrapper .duration h3 i').toggleClass('fa-rotate-180')
    
    if $('.new-goal-wrapper .duration').hasClass('active')
      $('.new-goal-wrapper #goal_duration').slider()
      
      update_slider($('.new-goal-wrapper #goal_duration').data('slider-value'))
      
      $('.new-goal-wrapper #goal_duration').on('slide', (slideEvt) ->
        update_slider_value(slideEvt.value)
      ).on('slideStop', (slideEvt) ->
        update_slider(slideEvt.value)
      )
    else
      setTimeout(->
        $('.new-goal-wrapper #goal_duration').slider('destroy')
      , 400)
  ).on('mousedown', (e) ->
    e.preventDefault()
  )
  
  $('.new-goal-wrapper .duration button').click (e) ->
    text = "for #{ $(this).data('value') } days"
    
    text = switch $(this).prop('id')
      when '3w' then "for 3 weeks"
      when '5w' then "for 5 weeks"
      when '10w' then "for 10 weeks"
      when '1m' then "for 1 month"
      when '3m' then "for 3 months"
      when '6m' then "for 6 months"
      when '1y' then "for 1 year"
    
    set_slider_button($(".new-goal-wrapper .duration button[data-value='#{ $(this).data('value') }']"))
    
    $('.new-goal-wrapper #goal_duration').slider('setValue', $(this).data('value'), true)
    
    $(".new-goal-wrapper .duration h3 span").text(text)
    $('.new-goal-wrapper #goal_duration_desc').val(text)
    
    e.preventDefault()
  
  # changing interval unit, day <-> week
  $('.new-goal-wrapper input[name="goal[interval_unit]"]').on('change', ->    
    update_frequency_title()
    show_end_date($('.new-goal-wrapper #goal_duration').data('sliderValue'))
  )
  
  # simply changing the day/days
  $('.new-goal-wrapper .frequency .day select').on('change', ->
    $('.new-goal-wrapper #goal_interval_unit_day').prop('checked', true)
    
    update_frequency_day_inverval()
    update_frequency_title()
  )
  
  # simply changing the weekly time/times
  $('.new-goal-wrapper .frequency .week select').on('change', ->
    $('.new-goal-wrapper #goal_interval_unit_week').prop('checked', true)
    
    update_frequency_week_times()
    
    w = $('.new-goal-wrapper .frequency label.checkbox-inline input:checked').length
    $('.new-goal-wrapper .frequency label.checkbox-inline input').prop('checked', false) if w != $('.new-goal-wrapper .frequency .week select').val()
    
    update_frequency_title()
  )
  
  # clicking on weekday checkboxes
  $('.new-goal-wrapper .frequency label.checkbox-inline input:checkbox').on('change', (e) ->
    $('.new-goal-wrapper #goal_interval_unit_week').prop('checked', true)
    
    w = $('.new-goal-wrapper .frequency label.checkbox-inline input:checked').length
    
    if w <= 0
      e.preventDefault() # can't deselect all
    else if w >= 7
      e.preventDefault() # should not select all
      $(this).prop('checked', false)
      $('.new-goal-wrapper .frequency .day select').val(1)
      $('.new-goal-wrapper #goal_interval_unit_day').prop('checked', true)
      
      update_frequency_day_inverval()
      update_frequency_title()
    else
      $('.new-goal-wrapper .frequency .week select').val(w)
    
      update_frequency_title()
  )
  
  # changing starting offset, day <-> week
  $('.new-goal-wrapper input[name="goal[starts]"]').on('change', ->
    show_end_date($('.new-goal-wrapper #goal_duration').data('sliderValue'))
  )
  
  
  $('.new-goal-wrapper .actions :submit').on('click', (e) ->
    if $('.new-goal-wrapper #goal_title').val().length == 0
      $('.new-goal-wrapper #goal_title').attr('placeholder', "need to describe the goal first...").addClass('error')
      clearTimeout(upmit.timeoutid)
      
      e.preventDefault()
  )

rotate_goal_samples = ->
  if upmit.timeoutid
    clearTimeout(upmit.timeoutid)
    
  upmit.timeoutid = setTimeout(rotater, 3000)

rotater = ->
  $('.new-goal-wrapper #goal_title').attr('placeholder', upmit.samples[upmit.currentSample++ % upmit.samples.length])
  rotate_goal_samples()

update_frequency_day_inverval = ->
  $('.new-goal-wrapper .frequency .day span').html(if $('.new-goal-wrapper .frequency .day select').val() > 1 then 'days' else 'day')
  
update_frequency_week_times = ->
  $('.new-goal-wrapper .frequency .week span').html(if $('.new-goal-wrapper .frequency .week select').val() > 1 then 'times' else 'time')
  

update_frequency_title = ->
  if $('.new-goal-wrapper input[name="goal[interval_unit]"]:checked').val() == 'day'
    d = $('.new-goal-wrapper .frequency .day select').val()
    
    if d > 1
      str = "every #{ d } days"
    else
      str = 'everyday'
      
    $('.new-goal-wrapper .starts label.left span').text('today').attr('title', '')
    $('.new-goal-wrapper .starts label.right span').text('tomorrow')
  else
    w = $('.new-goal-wrapper .frequency .week select').val()
    t = if w > 1 then 'times' else 'time'
    str = "#{ w } #{ t } a week"
    
    output = 'this week'
    output = '<i class="fa fa-exclamation"></i> ' + output if upmit.now.getDay() > 1
    
    $('.new-goal-wrapper .starts label.left span').html(output)
    
    if upmit.now.getDay() > 1
      $('.new-goal-wrapper .starts label.left')
      .attr('title', 'Days has passed in this week, are you sure you want to start your goal this week?')
      .data('toggle', "tooltip")
      .data('placement', "top")
      
      $('.new-goal-wrapper .starts label.left').tooltip()
    else
      $('.new-goal-wrapper .starts label.left').attr('title', '')
    
    $('.new-goal-wrapper .starts label.right span').text('next week')
    
  $('.new-goal-wrapper .frequency h3 span').html(str)

set_slider_button = (el) ->
  $('.new-goal-wrapper .duration button').removeClass('active')
  el.addClass('active')

update_slider = (value) ->
  update_slider_value(value)
  
  button = $(".new-goal-wrapper .duration button[data-value='#{ value }']")
  
  if button.length > 0
    set_slider_button(button)
  else
    $('.new-goal-wrapper .duration button').removeClass('active')

update_slider_value = (value) ->
  $(".new-goal-wrapper .duration h3 span").text("for #{ value } days")
  $('.new-goal-wrapper #goal_duration').data('sliderValue', value)
  show_end_date(value)

show_end_date = (value) ->
  if $('.new-goal-wrapper input[name="goal[interval_unit]"]:checked').val() == 'week'
    if $('.new-goal-wrapper input[name="goal[starts]"]:checked').val() == '1'
      value = value - upmit.now.getDay() + 7
    else
      value = value - upmit.now.getDay()
  else
    if $('.new-goal-wrapper input[name="goal[starts]"]:checked').val() == '1'
      value += 1      
    
  $('.new-goal-wrapper .duration .date').html('finishes on ' + upmit.now.addDays(value - 1).toLocaleDateString())
  