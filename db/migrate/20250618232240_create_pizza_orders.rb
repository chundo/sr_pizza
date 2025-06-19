class CreatePizzaOrders < ActiveRecord::Migration[8.0]
  def change
    create_table :pizza_orders do |t|
      t.string :customer_name, null: false
      t.string :pizza_type, null: false
      t.string :size, null: false
      t.timestamps
    end
  end
end
