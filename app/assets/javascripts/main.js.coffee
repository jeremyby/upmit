$(document).ready ->
  upmit.timer = 0
  timezone = jstz.determine()
  
  $('.donut').circliful()
  
  
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

      # hide all other pop-dialogs
      $(".notification-dropdown .pop-dialog").removeClass "is-visible"
      $(".notification-dropdown .trigger").removeClass "active"
      $dialog.toggleClass "is-visible"
      if $dialog.hasClass("is-visible")
        $(this).addClass "active"
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
  
  
  
show_chart = (d) ->
  setTimeout( ->
    $(d).circliful()
  , upmit.timer )
  
  upmit.timer += 500
  
Date.prototype.addDays = (days) ->
  dat = new Date(this.valueOf())
  dat.setDate(dat.getDate() + days)
  return dat
