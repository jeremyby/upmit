$(document).ready ->
  upmit.timer = 0
  
  show_chart donut for donut in $('.donut')
  
show_chart = (d) ->
  setTimeout( ->
    $(d).circliful()
  , upmit.timer )
  
  upmit.timer += 300
  
Date.prototype.addDays = (days) ->
  dat = new Date(this.valueOf())
  dat.setDate(dat.getDate() + days)
  return dat
