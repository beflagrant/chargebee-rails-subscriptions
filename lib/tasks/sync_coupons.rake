require 'chargebee_rails/sync_coupons'

namespace :chargebee_rails do
  desc "chargebee coupon sync with application"
  task sync_coupons: :environment do
    ChargebeeRails::SyncCoupons.sync
  end

end
