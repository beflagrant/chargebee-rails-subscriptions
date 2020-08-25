module ChargebeeRails
  class CustomerBuilder

    def initialize(customer, options)
      @customer = customer
      @options  = options
    end

    # Create a customer in Chargebee,
    # update the resulting customer details in the
    # application and finally return the customer
    def create
      create_customers
      @customer
    end

    # Update existing customer in Chargebee,
    # the resulting customer details are then updated in application
    def update
      update_customers
      @customer
    end

    private

    # Create a customer in Chargebee with the passed options payload
    # and the application model
    def create_customers
      @result = ChargeBee::Customer.create(@options)
      @customer.update(
        chargebee_id:   chargebee_customer.id,
        chargebee_data: chargebee_customer_data,
      )
    end

    # Update customer in ChargeBee and the application model
    def update_customers
      @subscription        = @customer.subscription
      @options[:prorate] ||= ChargebeeRails.configuration.proration
      @result              = ChargeBee::Subscription.update(@subscription.chargebee_id, @options)
      @plan                = Plan.find_by(plan_id: @result.subscription.plan_id)
      @subscription.update(subscription_attrs)
    end

    def chargebee_customer
      @chargebee_customer ||= @result.customer
    end

    def customer_attrs
      {
        chargebee_id:   chargebee_subscription.id,
        status:         chargebee_subscription.status,
        plan_quantity:  chargebee_subscription.plan_quantity,
        chargebee_data: chargebee_subscription_data,
        plan:           @plan,
      }
    end

    def chargebee_customer_data
      {
        customer_details: customer_details(chargebee_customer),
        billing_address:  billing_address(chargebee_customer.billing_address)
      }
    end

    def customer_details(customer)
      {
        first_name: customer.first_name,
        last_name:  customer.last_name,
        email:      customer.email,
        phone:      customer.phone,
        company:    customer.company,
        vat_number: customer.vat_number,
      }
    end

    def billing_address(customer_billing_address)
      return if customer_billing_address.nil?

      {
        first_name:    customer_billing_address.first_name,
        last_name:     customer_billing_address.last_name,
        company:       customer_billing_address.company,
        address_line1: customer_billing_address.line1,
        address_line2: customer_billing_address.line2,
        address_line3: customer_billing_address.line3,
        city:          customer_billing_address.city,
        state:         customer_billing_address.state,
        country:       customer_billing_address.country,
        zip:           customer_billing_address.zip,
      }
    end
  end
end
