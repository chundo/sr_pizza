class WinnerSelectionController < ApplicationController
  # POST /winner_selection
  def select_winner
    service = WinnerSelectionService.new

    if service.select_winner
      render json: {
        status: "success",
        winner: {
          id: service.winner.id,
          customer_name: service.winner.customer_name,
          pizza_type: service.winner.pizza_type,
          size: service.winner.size,
          order_date: service.winner.created_at
        }
      }, status: :ok
    else
      render json: {
        status: "failed",
        errors: service.errors
      }, status: :unprocessable_entity
    end
  end
end
