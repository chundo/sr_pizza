class PricingService
  DEFAULT_VAT_RATE = 0.19

  # Base prices by pizza type and size
  PRICES = {
    'margherita' => { 'small' => 12.00, 'medium' => 16.00, 'large' => 20.00 },
    'pepperoni' => { 'small' => 14.00, 'medium' => 18.00, 'large' => 22.00 },
    'vegetarian' => { 'small' => 13.00, 'medium' => 17.00, 'large' => 21.00 }
  }.freeze

  attr_reader :pizza_type, :size, :vat_rate, :base_price, :vat_amount, :total_price

  def initialize(pizza_type, size, vat_rate: DEFAULT_VAT_RATE)
    @pizza_type = pizza_type
    @size = size
    @vat_rate = vat_rate
    calculate
  end

  def self.calculate_for_order(pizza_type, size, vat_rate: DEFAULT_VAT_RATE)
    new(pizza_type, size, vat_rate: vat_rate)
  end

  def to_h
    {
      base_price: base_price,
      vat_rate: vat_rate,
      vat_amount: vat_amount,
      total_price: total_price
    }
  end

  private

  def calculate
    @base_price = PRICES.dig(pizza_type, size)
    return unless @base_price

    @vat_amount = (@base_price * @vat_rate).round(2)
    @total_price = (@base_price + @vat_amount).round(2)
  end
end