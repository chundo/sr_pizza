class AddPricingToPizzaOrders < ActiveRecord::Migration[8.0]
  def change
    add_column :pizza_orders, :base_price, :decimal, precision: 8, scale: 2
    add_column :pizza_orders, :vat_rate, :decimal, precision: 5, scale: 4, default: 0.19
    add_column :pizza_orders, :vat_amount, :decimal, precision: 8, scale: 2
    add_column :pizza_orders, :total_price, :decimal, precision: 8, scale: 2
  end
end