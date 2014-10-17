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

Facebook_user_access_token = 'CAAKGphkBwO4BAKp2BJgWQiRWdMg3FZCzjiKKlPuHSYsZAwjgaEYBEskVA2ews9EjPPy3ADOSdS3Ye7Dc2fRqDjiqnZB99F1z0aYfkE0B7f9keyslkaKHD9MKjv81cHhUZCya3Q25ZCWyT8zqFQxuN1CmLGiZCTVb2kng5gfgOg51ClhseZA1q7Q'
Facebook_page_id = '720802234659954'

