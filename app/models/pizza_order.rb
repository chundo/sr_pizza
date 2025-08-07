class PizzaOrder < ApplicationRecord
    PIZZA_TYPES = %w[margherita pepperoni vegetarian].freeze
    SIZES = %w[small medium large].freeze
    
    # Base prices by pizza type and size
    BASE_PRICES = {
      'margherita' => { 'small' => 12.00, 'medium' => 16.00, 'large' => 20.00 },
      'pepperoni' => { 'small' => 14.00, 'medium' => 18.00, 'large' => 22.00 },
      'vegetarian' => { 'small' => 13.00, 'medium' => 17.00, 'large' => 21.00 }
    }.freeze

    validates :customer_name, :pizza_type, :size, presence: true
    validates :pizza_type, inclusion: { in: PIZZA_TYPES }
    validates :size, inclusion: { in: SIZES }
    validates :base_price, :vat_rate, :vat_amount, :total_price, presence: true, if: :pricing_calculated?

    enum :pizza_type, { margherita: "margherita", pepperoni: "pepperoni", vegetarian: "vegetarian" }
    enum :size, { small: "small", medium: "medium", large: "large" }

    before_save :calculate_pricing, if: :should_calculate_pricing?

    def calculate_pricing!
      return unless pizza_type.present? && size.present?
      
      pricing = PricingService.new(pizza_type, size, vat_rate: vat_rate || 0.19)
      
      self.base_price = pricing.base_price
      self.vat_rate = pricing.vat_rate
      self.vat_amount = pricing.vat_amount
      self.total_price = pricing.total_price
    end

    private

    def calculate_pricing
      calculate_pricing!
    end

    def should_calculate_pricing?
      (pizza_type_changed? || size_changed? || vat_rate_changed?) && pizza_type.present? && size.present?
    end

    def pricing_calculated?
      base_price.present?
    end
end
