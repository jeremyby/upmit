# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

$(document).ready ->
  ######################################
  # Finish Signup
  ######################################
  
  $('.finish_signup #user_timezone').set_timezone()
  
  
  ######################################
  #
  ######################################
  
  $('.setting-wrapper .editable').editable({
    onblur: 'ignore',
    success: (response, newValue) ->
      upmit.stop_spinner()
      
      if $(response).length # username updated, with new user url returned
        upmit.message('Username was successfully updated.', 'notice')
        $('.setting-wrapper .username p.help-block').html(response.url)
      
      if $(this).data('name') == 'user[email]'
        upmit.message('A confirmation letter was sent to your new email address.', 'notice')
  })
  
  if $('.setting-wrapper .editable_select').length
    upmit.timezones = []
    keys = Object.keys(jstz.olson.timezones)
  
    for k in keys
      tz = jstz.olson.timezones[k]
      upmit.timezones.push({ value: tz.olson_tz, text: tz.utc_offset + ' ' + tz.olson_tz })
  
  
  $('.setting-wrapper .editable_select').editable({
    onblur: 'ignore',
    source: upmit.timezones,
    success: ->
      upmit.message('Timezone was successfully updated.', 'notice')
      upmit.stop_spinner()
  })
  
  $('.login-wrapper #user_timezone').set_timezone()
  
  $('.setting-wrapper .editable-area').editable({
    onblur: 'ignore',
    showbuttons: 'bottom',
    rows: 3,
    emptytext: 'Nothing yet',
    success: (response, newValue) ->
      upmit.stop_spinner()
  })
  
  
  $('.setting-wrapper .editable, .setting-wrapper .editable_select').on('save', ->
    upmit.start_spinner()
  )
  
  $('.setting-wrapper .password form').submit ->
    upmit.start_spinner()
    
  
  
  $('.setting-wrapper .password form').bind('ajax:error', (xhr, data, status) ->
    upmit.stop_spinner()
    
    errors = $.parseJSON(data.responseText)
    
    upmit.debug=errors
    
    if $(errors.current_password).length
      $('.setting-wrapper #user_current_password').attr('title', errors.current_password).tooltip('show')
    
    if $(errors.password).length
      $('.setting-wrapper #user_password').attr('title', errors.password).tooltip('show')
      
    if $(errors.password_confirmation).length
      $('.setting-wrapper #user_password_confirmation').attr('title', errors.password_confirmation).tooltip('show')
    
  ).bind('ajax:success', (xhr, data, status) ->
    upmit.stop_spinner()
    
    upmit.message('Password was successfully updated.', 'notice')
    
    setTimeout(->
      $('.setting-wrapper .password input').prop('disabled', true)
    , 100)
  )
  
  $('.setting-wrapper .password form input').keydown ->
    $(this).tooltip('destroy')
    
    
    
    
  ##################
  # Profile
  ##################
  
  $('.setting-wrapper .avatar form').bind('ajax:beforeSend', (e, request, options) ->
    if $('.setting-wrapper .avatar #user_avatar').val().length == 0 && $('.setting-wrapper .avatar #user_remote_avatar_url').val().length == 0
      e.preventDefault()

      upmit.message('Please upload a photo or submit a url to a remote one.', 'alert')
      return false
    else
      upmit.start_spinner()
  ).bind('ajax:success', (xhr, data, status) ->
    upmit.stop_spinner()
    
    upmit.message('Your photo was successfully updated.', 'notice')
    
    $('.setting-wrapper .avatar .current img').attr('src', data.avatar)
  ).bind('ajax:error', (xhr, data, status) ->
    upmit.stop_spinner()
    
    upmit.message('There was problem updating your photo. Please try again.', 'alert')
  )
  
  ##################
  # Preference
  ##################
  
  $('.setting-wrapper .reminder form input[name="user[reminder][email]"]').on('change', (e) ->
    upmit.start_spinner()
    
    $('.setting-wrapper .reminder form .email .btn-group').addClass('disabled').prop('disabled', true)
    
    $('.setting-wrapper .reminder #user_reminder_change').val('email')
    
    $('.setting-wrapper .reminder form input[type="submit"]').click()
  )
  
  $('.setting-wrapper .reminder form input[name="user[reminder][twitter]"]').on('change', (e) ->
    upmit.start_spinner()
    
    $('.setting-wrapper .reminder form .twitter .btn-group').addClass('disabled').prop('disabled', true)
    
    $('.setting-wrapper .reminder #user_reminder_change').val('twitter')
    
    $('.setting-wrapper .reminder form input[type="submit"]').click()
  )
  
  $('.setting-wrapper .reminder form').on('ajax:success', (xhr, data, status) ->
    upmit.stop_spinner()
    upmit.message('Your reminder preference was successfully updated.', 'notice')
    
    setTimeout(->
      $('.setting-wrapper .reminder form .btn-group.disabled').prop('disabled', false).removeClass('disabled')
    , 500)
  ).on('ajax:error', (xhr, data, status) ->
    upmit.stop_spinner()
    upmit.message('Something went wrong. Please reload the page and try again.', 'alert')
  )