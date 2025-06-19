class PizzaOrder < ApplicationRecord
    PIZZA_TYPES = %w[margherita pepperoni vegetarian].freeze
    SIZES = %w[small medium large].freeze

    validates :customer_name, :pizza_type, :size, presence: true
    validates :pizza_type, inclusion: { in: PIZZA_TYPES }
    validates :size, inclusion: { in: SIZES }

    enum :pizza_type, { margherita: "margherita", pepperoni: "pepperoni", vegetarian: "vegetarian" }
    enum :size, { small: "small", medium: "medium", large: "large" }
end
