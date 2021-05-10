module ChargebeeRails
  class SyncCoupons
    attr_accessor :messages

  	def self.sync(create: true, update: true, delete: false)
  		syncer = SyncCoupons.new
  		return syncer.do_sync(create: create, update: update, delete: delete)
  	end

  	def do_sync(create: true, update: true, delete: false)
  		self.get_coupons
  		self.sync_coupons(create: create, update:u pdate, delete: delete)

      return messages
  	end

    protected

    def output(message)
      Rails.logger.info(message)
      self.messages ||= []
      self.messages << message
    end

    def get_coupons
        loop do
          coupon_list = retrieve_coupon_list
          @offset     = coupon_list.next_offset
          cb_coupons << coupon_list.flat_map(&:coupon)
          break unless @offset.present?
        end
        @cb_coupons = cb_coupons.flatten
    end

    def cb_coupons
      @cb_coupons ||= []
    end

    def sync_coupons(create: true, update: true, delete: false)
      output "Removed #{remove_coupons.count} coupon(s)" if (delete)
      output "Created #{create_new_coupons.count} coupon(s)" if (create)
      output "Updated all #{update_all_coupons.count} coupon(s)" if (update)
    end

    # Retrieve the coupon list from chargebee
    def retrieve_coupon_list
      options = { limit: 100 }
      options[:offset] = @offset if @offset.present?
      ChargeBee::Coupon.list(options)
    end

    # Remove coupons from application that do not exist in chargebee
    def remove_coupons
      cb_coupon_ids = cb_coupons.flat_map(&:id)
      Coupon.all.reject { |coupon| cb_coupon_ids.include?(coupon.coupon_id) }
              .each   { |coupon| output "Deleting Coupon - #{coupon.coupon_id}"; coupon.destroy }
    end

    # Create new coupons that are not present in app but are available in chargebee
    def create_new_coupons
      coupon_ids = Coupon.all.map(&:coupon_id)
      cb_coupons.reject { |cb_coupon| coupon_ids.include?(cb_coupon.id) }
              .each   { |new_coupon| output "Creating Coupon - #{new_coupon.id}"; Coupon.create(coupon_params(new_coupon)) }
    end

    # Update all existing coupons in the application
    def update_all_coupons
      cb_coupons.map do |cb_coupon|
        Coupon.find_by(coupon_id: cb_coupon.id).update(coupon_params(cb_coupon))
      end
    end

    # Build the coupon params to be created or updated in the application
    def coupon_params(coupon)
      {
        name: coupon.name,
        coupon_id: coupon.id,
        status: coupon.status,
        chargebee_data: {
          addon_constraint: coupon.addon_constraint,
          apply_discount_on: coupon.apply_discount_on,
          apply_on: coupon.apply_on,
          currency_code: coupon.currency_code,
          discount_amount: coupon.discount_amount,
          discount_type: coupon.discount_type,
          duration_type: coupon.duration_type,
          id: coupon.coupon.id,
          name: coupon.name,
          plan_constraint: coupon.plan_constraint,
        }
      }
    end

  end
end
