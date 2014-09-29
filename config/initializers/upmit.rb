require 'active_support/time'

require 'stateable'

# CDN/external file settings
case Rails.env
when 'development'
  FONT_SITE = 'fonts.useso.com'
  CDN = '/assets/lib'
  PAYPAL_DG = '/assets/lib'
  PAYPAL_BUTTON = '/assets/'
else
  FONT_SITE = 'fonts.googleapis.com'
  CDN = '//maxcdn.bootstrapcdn.com'
  PAYPAL_DG = 'https://www.paypalobjects.com/js/external'
  PAYPAL_BUTTON = 'https://www.paypal.com/en_US/i/btn'
end
