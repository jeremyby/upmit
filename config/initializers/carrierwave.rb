require 'fog/aws/storage'
require 'carrierwave'

CarrierWave::SanitizedFile.sanitize_regexp = /[^[:word:]\.\-\+]/

CarrierWave.configure do |config|

  if Rails.env.development? || Rails.env.test?
    config.storage = :file
  else
    config.storage = :fog
    config.fog_credentials = {
      :provider               => 'AWS',
      :aws_access_key_id      =>  'AKIAJIHRGWHE6L2VFPUQ',
      :aws_secret_access_key  => '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',
      :region                 => 'us-west-2'
    }
    config.fog_directory = 'upmit'
    config.asset_host = 'di9lli9s5lmc4.cloudfront.net'
  end
end