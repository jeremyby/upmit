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

Facebook_user_access_token = 'CAAKGpkLtxH0BAJvLpLctBuKf5N2i9tQF29dJLpSSVVE9UM3XMZA4xzoiZAykkK6W8sucXm51hHuWSV4pSlzrNsBHX0PExIITyTJyPzbakqIVhriwD7tHUPHKG8FlF4ybS07LGKTAal1JhSq7ezpFyRQ8js6E5pwbZA3M03hKcvMSK6TJ5MtNioqF9viTOQvZBohm29dISxFvDzVBb1TJ'
