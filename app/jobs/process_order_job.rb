class ProcessOrderJob < ApplicationJob
  # include Sidekiq::Job
  queue_as :default

  def perform(order_id)
    order = PizzaOrder.find(order_id)
    # Simular cocción: registrar o agregar un retraso
    Rails.logger.info "Procesando pedido #{order.id} para #{order.customer_name}"
    sleep(5) # Simular tiempo de cocción
    Rails.logger.info "Pedido #{order.id} completado"
  rescue ActiveRecord::RecordNotFound => e
    Rails.logger.error "No se encontró la orden con ID: #{order_id}"
  rescue StandardError => e
    Rails.logger.error "Error procesando orden #{order_id}: #{e.message}"
    raise e
  end
end