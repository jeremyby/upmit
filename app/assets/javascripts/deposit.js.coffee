$(document).ready ->
  upmit.dg = new PAYPAL.apps.DGFlow({
  # HTML ID of form submit buttons that call setEC
  trigger:'paypal_submit'
  })
  

