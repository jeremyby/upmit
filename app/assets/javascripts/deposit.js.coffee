$(document).ready ->
  upmit.dg = new PAYPAL.apps.DGFlow({
  # HTML ID of form submit buttons that call setEC
  trigger:'paypal_submit'
  })
  
  
  $('.refund-total .list a').on('click', (e) ->
    e.preventDefault()
    
    if $('.row.history').is(':visible')
      $(this).find('i').removeClass 'fa-rotate-180'
      $('.row.history').slideUp()
    else
      $(this).find('i').addClass 'fa-rotate-180'
      $('.row.history').slideDown()
  )

