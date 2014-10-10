require 'active_support/time'

require 'stateable'

# CDN/external file settings
case Rails.env
when 'development'
  FONT_SITE = 'http://fonts.useso.com'
  CDN = '/assets/lib'
  PAYPAL_DG = '/assets/lib'
  PAYPAL_BUTTON = '/assets/'
else
  FONT_SITE = 'https://fonts.googleapis.com'
  CDN = '//maxcdn.bootstrapcdn.com'
  PAYPAL_DG = 'https://www.paypalobjects.com/js/external'
  PAYPAL_BUTTON = 'https://www.paypal.com/en_US/i/btn'
end

# 'upmit_dev.mention_pointers'
UpmitMentionSince = MentionPointer.find_or_create_by(id: 1) if ActiveRecord::Base.connection.table_exists? 'mention_pointers'

Facebook_user_access_token = 'CAAKGpkLtxH0BALmsphgDYNHUZBQ8m5jrDIS1JqiKSEcKHF1zMPMhZBZC6ZBo46xTcVPD2uD031u7Gkb5ZCfCpKVs04gLpiMZAaFZC2y77j45eDVxXJFCTRoWm4lmZCdgZAL4fMWGhd5zLtDENBIVpCHTpiNyfUHju6CQnaYBcgBYVE36nnFGS9wZBn1F1sju6qZBPYNC2zkOZA6tZApzDA1k5QxFG'
Facebook_page_id = '720802234659954'