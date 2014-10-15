$(document).ready ->
  upmit.timer = 0
  upmit.spinner = $('.navbar .settings i.fa-cog')
  
  
  $.fn.editableform.buttons = 
    '<button type="submit" class="btn btn-primary btn-sm editable-submit">'+
      '<i class="fa fa-check"></i>'+
    '</button>'+
    '<button type="button" class="btn btn-default btn-sm editable-cancel">'+
      '<i class="fa fa-times"></i>'+
    '</button>';         
  
  
  $.fn.poof = (speed) ->
    poofer = $(this)
    i = switch speed
      when 'slow' then 10000
      when 'fast' then 4000
      else 7000

    setTimeout(->
      poofer.slideUp()
     , i)
  
  upmit.message = (message, type = 'alert') ->
    icon = if type == 'alert' then "<i class='fa fa-times-circle'></i> " else "<i class='fa fa-exclamation-circle'></i> "
    classes = if type == 'alert' then "text alert alert-danger" else "text alert alert-info"
    
    $('#messages').html("<div class='#{ classes }'>" + icon + message + '</div>').slideDown().poof()
  
  
  if $('#messages').html().length > 0
    $('#messages.on').slideDown().poof('slow')
    
    
  
  upmit.start_spinner = ->
    upmit.spinner.addClass('fa-spin')
  
  upmit.stop_spinner = ->
    setTimeout(->
      upmit.spinner.removeClass('fa-spin')
    , 500)
    
  
  
  $('.donut').circliful()
  
  $('.field_with_errors input').tooltip('show')
  
  $('.field_with_errors input').keydown ->
    $(this).tooltip('destroy')
    $(this).closest('.field_with_errors').removeClass('field_with_errors')
  
  $(".notification-dropdown").each (index, el) ->
    $el = $(el)
    $dialog = $el.find(".pop-dialog")
    $trigger = $el.find(".trigger")
    $dialog.click (e) ->
      e.stopPropagation()


    $dialog.find(".close-icon").click (e) ->
      e.preventDefault()
      $dialog.removeClass "is-visible"
      $trigger.removeClass "active"


    $("body").click ->
      $dialog.removeClass "is-visible"
      $trigger.removeClass "active"


    $trigger.click (e) ->
      e.preventDefault()
      e.stopPropagation()
      
      $dialog.toggleClass "is-visible"
      
      if $dialog.hasClass("is-visible")
        $(this).addClass "active"
        
        if $trigger.find('.count').is(':visible')
          $.post("/notifications/read", ->
            $trigger.find('.count').hide('poof')
          )
      else
        $(this).removeClass "active"


  $("#dashboard-menu .dropdown-toggle").click (e) ->
    e.preventDefault()
    $item = $(this).parent()
    $item.toggleClass "active"
    if $item.hasClass("active")
      $item.find("i.fa-chevron-down").addClass('fa-rotate-180')
      $item.find(".submenu").slideDown "fast"
    else
      $item.find(".submenu").slideUp "fast"
      $item.find("i.fa-chevron-down").removeClass('fa-rotate-180')

  
  $menu = $("#sidebar-nav")
  
  $("body").click ->
    $(this).removeClass "menu"  if $(this).hasClass("menu")

  $("#menu-toggler").click (e) ->
    e.stopPropagation()
    $("body").toggleClass "menu"

  $(window).resize ->
    $(this).width() > 769 and $("body.menu").removeClass("menu")

  # fix for the left-shifting of bootstrap modal when hidding
  $.fn.modal.Constructor.prototype.setScrollbar = ->
    $('body').css('padding-right', '')
  
  
  $('.check-in a').on('click', (e) ->
    upmit.start_spinner()
    
    $(this).closest('.occurs').fadeOut()
  )
  
  
  
  if $('.panel-content').length
    $('#sidebar-nav').hover(->
      $('.panel-content, .owner').css('margin-left', '177px').css('z-index', '999')
    , ->
      $('.panel-content, .owner').css('z-index', '').css('margin-left', '')
    )
  
  
  $(".nav-tabs a[href='#remote']").click ->
    setTimeout(->
      $('.tab-content input[type="text"]').focus()
    , 100)
  
  
  $('.active-goal .check .fa-stack').click ->
    $(this).toggleClass('active')
    
    textarea = $('.checkin textarea')
  
    if $(this).hasClass('active')
      textarea.val(textarea.val() + ' ' + $(this).data('hash-tag'))
      
      if $('.checkin').is(':hidden')
        $('.checkin').fadeIn()
    else
      if !$('.active-goal .check .fa-stack').hasClass('active')
        $('.checkin').fadeOut()
    
      text = textarea.val()
      
      n =  text.search($(this).data('hash-tag'))
      replace_string = if text[n-1] == ' ' then ' ' + $(this).data('hash-tag') else $(this).data('hash-tag')

      textarea.val(text.replace(replace_string, ''))
  
  $('.checkin form').on('submit', ->
    NProgress.start()
    
  )

  
  
show_chart = (d) ->
  setTimeout( ->
    $(d).circliful()
  , upmit.timer )
  
  upmit.timer += 500
  
Date.prototype.addDays = (days) ->
  dat = new Date(this.valueOf())
  dat.setDate(dat.getDate() + days)
  return dat
