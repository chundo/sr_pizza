class PizzaOrdersController < ApplicationController
  before_action :set_pizza_order, only: %i[ show update destroy ]

  # GET /pizza_orders
  def index
    @pizza_orders = PizzaOrder.all

    render json: @pizza_orders
  end

  # GET /pizza_orders/1
  def show
    render json: @pizza_order
  end

  # POST /pizza_orders
  def create
    service = PizzaOrderService.new(pizza_order_params)
    if service.process
      render json: { status: "success" }, status: :created
    else
      render json: { status: "failed", errors: service.errors }, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /pizza_orders/1
  def update
    if @pizza_order.update(pizza_order_params)
      render json: @pizza_order
    else
      render json: @pizza_order.errors, status: :unprocessable_entity
    end
  end

  # DELETE /pizza_orders/1
  def destroy
    @pizza_order.destroy!
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_pizza_order
      @pizza_order = PizzaOrder.find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def pizza_order_params
      params.expect(pizza_order: [ :customer_name, :pizza_type, :size ])
    end
end
