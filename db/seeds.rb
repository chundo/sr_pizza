# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

puts "🍕 Creando pedidos de pizza de ejemplo..."

# Limpiar datos existentes (solo en desarrollo)
if Rails.env.development?
  PizzaOrder.delete_all
  puts "   Datos anteriores eliminados"
end

# Array de clientes ficticios
customers = [
  "Ana García López",
  "Carlos Rodríguez",
  "María Fernández",
  "José Luis Martín",
  "Isabel Sánchez",
  "Miguel Ángel Torres",
  "Carmen Ruiz",
  "Francisco Jiménez",
  "Elena Moreno",
  "David Álvarez"
]

# Array de tipos de pizza disponibles
pizza_types = %w[margherita pepperoni vegetarian]

# Array de tamaños disponibles
sizes = %w[small medium large]

# Crear 10 pedidos de ejemplo
orders_data = [
  { customer_name: customers[0], pizza_type: "margherita", size: "medium" },
  { customer_name: customers[1], pizza_type: "pepperoni", size: "large" },
  { customer_name: customers[2], pizza_type: "vegetarian", size: "small" },
  { customer_name: customers[3], pizza_type: "pepperoni", size: "medium" },
  { customer_name: customers[4], pizza_type: "margherita", size: "large" },
  { customer_name: customers[5], pizza_type: "vegetarian", size: "medium" },
  { customer_name: customers[6], pizza_type: "pepperoni", size: "small" },
  { customer_name: customers[7], pizza_type: "margherita", size: "small" },
  { customer_name: customers[8], pizza_type: "vegetarian", size: "large" },
  { customer_name: customers[9], pizza_type: "pepperoni", size: "medium" }
]

created_orders = []

orders_data.each_with_index do |order_data, index|
  order = PizzaOrder.find_or_create_by!(
    customer_name: order_data[:customer_name],
    pizza_type: order_data[:pizza_type],
    size: order_data[:size]
  )

  created_orders << order
  puts "   ✅ Pedido #{index + 1}: #{order.customer_name} - #{order.pizza_type.humanize} (#{order.size.humanize})"
end

puts "\n🎉 ¡Seeds completado exitosamente!"
puts "   📊 Total de pedidos creados: #{created_orders.size}"
puts "   🍕 Tipos de pizza:"
puts "      - Margherita: #{created_orders.count { |o| o.pizza_type == 'margherita' }} pedidos"
puts "      - Pepperoni: #{created_orders.count { |o| o.pizza_type == 'pepperoni' }} pedidos"
puts "      - Vegetarian: #{created_orders.count { |o| o.pizza_type == 'vegetarian' }} pedidos"
puts "   📏 Tamaños:"
puts "      - Small: #{created_orders.count { |o| o.size == 'small' }} pedidos"
puts "      - Medium: #{created_orders.count { |o| o.size == 'medium' }} pedidos"
puts "      - Large: #{created_orders.count { |o| o.size == 'large' }} pedidos"
puts "\n💡 Usa 'curl http://localhost:3000/pizza_orders' para ver todos los pedidos"
