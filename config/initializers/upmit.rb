require 'active_support/time'

require 'stateable'

# CDN/external file settings
case Rails.env
when 'development'
  FONT_SITE = 'fonts.useso.com'
  CDN = 'http://libs.useso.com/js'
  PAYPAL_DG = '/assets/lib'
  PAYPAL_BUTTON = '/assets/'

when 'production'
  FONT_SITE = 'fonts.googleapis.com'
  CDN = '//maxcdn.bootstrapcdn.com'
  PAYPAL_DG = 'https://www.paypalobjects.com/js/external'
  PAYPAL_BUTTON = 'https://www.paypal.com/en_US/i/btn'
end

# Dumb filter for goal legend
LEGEND_MAP = {
  'run'       => ['run', 'jog'],
  'swim'      => ['swim', 'pool'],
  'smoke'     => ['smoke', 'cigarette'],
  'dumbbell'  => ['work out', 'lift', 'gym'],
  'happy'     => ['positive', 'happy', 'sad'],
  'open'      => ['experience', 'new', 'try', 'open'],
  'check'     => ['procrastinat', 'work'],
  'plane'     => ['travel', 'up'],
  'diet'      => ['diet', 'weight', 'pound', 'eat'],
  'golf'      => ['golf']
}
