require 'chargebee_rails/sync_plans'
require 'chargebee_rails/sync_coupons'

namespace :chargebee_rails do
  #include ChargebeeRails#

  desc "chargebee plans sync with application"
  task :sync_plans => :environment do
    ChargebeeRails::SyncPlans.sync
  end

  desc "chargebee plans sync with application"
  task sync_plans: :environment do
    ChargebeeRails::SyncCoupons.sync
  end

end
