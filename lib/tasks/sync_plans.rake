require 'chargebee_rails/sync_plans'

namespace :chargebee_rails do
  desc "chargebee plans sync with application"
  task :sync_plans => :environment do
    ChargebeeRails::SyncPlans.sync
  end
end
