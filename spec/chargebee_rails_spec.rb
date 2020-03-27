# frozen_string_literal: true

require 'spec_helper'
require 'sample_class'

describe "chargebee_rails" do
  describe "#as_chargebee_customer" do
    let(:chargebee_id) { 'cbdemo_dave' }

    it 'returns its corresponding Chargebee customer object' do
      user = User.new
      user.chargebee_id = chargebee_id

      customer = ChargeBee::Customer.retrieve(chargebee_id).customer
      subscriber = user.as_chargebee_customer

      expect(subscriber).to be_an_instance_of ChargeBee::Customer
      expect(subscriber.id).to eq(customer.id)
    end
  end

  describe "#configuration" do
    it 'should configure the default values for the application' do
      expect(ChargebeeRails.configuration.default_plan_id).to be_nil
      expect(ChargebeeRails.configuration.end_of_term).to be false
      expect(ChargebeeRails.configuration.include_delayed_charges[:changes_estimate]).to be false
      expect(ChargebeeRails.configuration.include_delayed_charges[:renewal_estimate]).to be true
      expect(ChargebeeRails.configuration.webhook_api_path).to eq 'chargebee_rails_event'
      expect(ChargebeeRails.configuration.secure_webhook_api).to be false
      expect(ChargebeeRails.configuration.webhook_authentication[:user]).to be nil
      expect(ChargebeeRails.configuration.webhook_authentication[:secret]).to be nil
      expect(ChargebeeRails.configuration.chargebee_site).to be nil
      expect(ChargebeeRails.configuration.chargebee_api_key).to be nil
      ChargebeeRails.configure do |config|
        config.default_plan_id = "sample_plan_id"
        config.end_of_term = true
        config.include_delayed_charges = { changes_estimate: true, renewal_estimate: false }
        config.webhook_api_path = 'webhook_events'
        config.secure_webhook_api = true
        config.webhook_authentication = { user: "test_user", secret: "test_pass" }
        config.chargebee_site = "dummy-site"
        config.chargebee_api_key = "dummy-api-key"
      end
      expect(ChargebeeRails.configuration.default_plan_id).to eq("sample_plan_id")
      expect(ChargebeeRails.configuration.end_of_term).to be true
      expect(ChargebeeRails.configuration.include_delayed_charges[:changes_estimate]).to be true
      expect(ChargebeeRails.configuration.include_delayed_charges[:renewal_estimate]).to be false
      expect(ChargebeeRails.configuration.webhook_api_path).to eq 'webhook_events'
      expect(ChargebeeRails.configuration.secure_webhook_api).to be true
      expect(ChargebeeRails.configuration.webhook_authentication[:user]).to eq 'test_user'
      expect(ChargebeeRails.configuration.webhook_authentication[:secret]).to eq 'test_pass'
      expect(ChargebeeRails.configuration.chargebee_site).to eq "dummy-site"
      expect(ChargebeeRails.configuration.chargebee_api_key).to eq "dummy-api-key"
    end
  end
end
