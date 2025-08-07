class PizzaOrderService
  attr_reader :errors, :order

  def initialize(params)
    @params = sanitize_params(params)
    @errors = []
    @order = nil
  end

  def process
    @order = PizzaOrder.new(@params)
    
    # Calculate pricing if not already set
    if @order.pizza_type.present? && @order.size.present? && @order.base_price.nil?
      @order.calculate_pricing!
    end

    if @order.save
      ProcessOrderJob.perform_later(@order.id)
      true
    else
      @errors = @order.errors.full_messages
      false
    end
  rescue StandardError => e
    @errors << "Error interno del servidor: #{e.message}"
    Rails.logger.error "Error en PizzaOrderService: #{e.message}"
    Rails.logger.error e.backtrace.join("\n")
    false
  end

  private

  def sanitize_params(params)
    # Convertir strings a símbolos para que coincidan con los enums
    sanitized = params.dup
    sanitized[:pizza_type] = params[:pizza_type]&.to_s&.downcase
    sanitized[:size] = params[:size]&.to_s&.downcase
    
    # Preserve pricing params if provided
    if params[:vat_rate] && params[:vat_rate].is_a?(Numeric)
      sanitized[:vat_rate] = params[:vat_rate]
    end
    
    sanitized
  end
end
