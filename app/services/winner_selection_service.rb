class WinnerSelectionService
  attr_reader :winner, :errors

  def initialize
    @winner = nil
    @errors = []
  end

  def select_winner
    orders = PizzaOrder.all

    if orders.empty?
      @errors << "No hay pedidos disponibles para seleccionar un ganador"
      return false
    end

    # Select a random winner from unique customers
    unique_customers = orders.pluck(:customer_name).uniq
    selected_customer = unique_customers.sample

    # Find the order for the selected customer (in case they have multiple orders, get the first one)
    @winner = orders.find_by(customer_name: selected_customer)

    true
  rescue StandardError => e
    @errors << "Error interno del servidor: #{e.message}"
    Rails.logger.error "Error en WinnerSelectionService: #{e.message}"
    Rails.logger.error e.backtrace.join("\n")
    false
  end
end
