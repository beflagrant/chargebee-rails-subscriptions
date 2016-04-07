module ChargebeeRails
  module ChargeableSubscription

    def self.included(base)
      base.extend(ClassMethods)
    end

    # Get the Chargebee equivalent subscription for the corresponding
    # active record subscription
    def as_chargebee_subscription
      ChargeBee::Subscription.retrieve(chargebee_id).subscription
    end


    def change_plan(plan, options={})
      options[:plan_id] = plan.plan_id
      options[:end_of_term] ||= ChargebeeRails.configuration.end_of_term
      subscription = ChargeBee::Subscription.update(chargebee_id, options).subscription
      update(
        chargebee_plan: subscription.plan_id,
        plan_id: plan.id,
        status: subscription.status
      ) unless options[:end_of_term]
    end

    # Cancel a subscription - it will be scheduled for cancellation at term end
    # when end_of_term is passed as true. If no options are passed the 
    # default configured value for end_of_term is taken
    def cancel(options={})
      options[:end_of_term] ||= ChargebeeRails.configuration.end_of_term
      subscription = ChargeBee::Subscription.cancel(chargebee_id, options).subscription
      update(
        status: subscription.status
      ) unless end_of_term
    end

    # Stop a scheduled cancellation of a subscription
    def stop_cancellation
      ChargeBee::Subscription.remove_scheduled_cancellation(chargebee_id).subscription
    end

    # Reactivate a cancelled subscription
    def reactivate
      subscription = ChargeBee::Subscription.reactivate(chargebee_id).subscription
      update(
        status: subscription.status
      )
    end

    # Estimates the subscription's renewal  
    def renewal_estimate(options={})
      options[:include_delayed_charges] ||= ChargebeeRails.configuration.include_delayed_charges[:renewal_estimate]
      ChargeBee::Estimate.renewal_estimate(chargebee_id, options).estimate
    end

    module ClassMethods
      
      # Estimates the cost of subscribing to a new subscription
      def estimate(estimation_params)
        ::ChargeBee::Estimate.create_subscription(estimation_params).estimate
      end

      # Estimates the cost of changes to an existing subscription
      # estimates the upgrade/downgrade or other changes
      def estimate_changes(estimation_params)
        estimation_params[:include_delayed_charges] ||= ChargebeeRails.configuration.include_delayed_charges[:changes_estimate]
        ::ChargeBee::Estimate.update_subscription(estimation_params).estimate
      end

    end

  end
end
