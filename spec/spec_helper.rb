# frozen_string_literal: true

require File.dirname(__FILE__) + '/../lib/chargebee_rails'
require 'rspec'
require 'webmock/rspec'
require 'mocha'
require 'vcr'
require 'pry'
require 'chargebee'

RSpec.configure do |config|
  # rspec-mocks config goes here. You can use an alternate test double
  # library (such as bogus or mocha) by changing the `mock_with` option here.
  config.mock_with :mocha
end

VCR.configure do |config|
  config.cassette_library_dir = 'spec/support/vcr_cassettes'
  config.hook_into :webmock
  config.configure_rspec_metadata!
  config.around_http_request do |request|
    VCR.use_cassette('chargebee_apis', record: :new_episodes, &request)
  end
end

ChargeBee.configure(site: 'dummy-site',
                    api_key: "dummy-api-key")
