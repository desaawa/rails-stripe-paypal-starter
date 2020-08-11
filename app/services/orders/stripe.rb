class Orders::Stripe
  INVALID_STRIPE_OPERATION = 'Invalid Stripe Operation'
  def self.execute(order:, user:)
    product = order.product
    # Check whether the order is a plan
    if product.stripe_plan_name.blank?
      charge = self.execute_charge(price_cents: product.price_cents,
                                   description: product.name,
                                   card_token:  order.token)
    else
  	 #SUBSCRIPTIONS WILL BE HANDLED HERE
    end

    unless charge&.id.blank?
      # If there is a charge with id, set order paid.
      order.charge_id = charge.id
      order.set_paid
    end
  rescue Stripe::StripeError => e
    # If a Stripe error is raised from the API,
    # set status failed and an error message
    order.error_message = INVALID_STRIPE_OPERATION
    order.set_failed
  end

  private
  def self.execute_charge(price_cents:, description:, card_token:)
    Stripe::Charge.create({
      amount: price_cents.to_s,
      currency: "usd",
      description: description,
      source: card_token
    })
  end
end