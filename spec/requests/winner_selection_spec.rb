require 'rails_helper'

RSpec.describe WinnerSelectionController, type: :request do
  describe 'POST /winner_selection' do
    context 'when there are pizza orders available' do
      let!(:order1) { PizzaOrder.create!(customer_name: 'Ana García', pizza_type: 'margherita', size: 'medium') }
      let!(:order2) { PizzaOrder.create!(customer_name: 'Carlos López', pizza_type: 'pepperoni', size: 'large') }
      let!(:order3) { PizzaOrder.create!(customer_name: 'María Fernández', pizza_type: 'vegetarian', size: 'small') }

      it 'returns a success response' do
        post '/winner_selection'
        expect(response).to have_http_status(:ok)
      end

      it 'returns success status in JSON' do
        post '/winner_selection'
        json_response = JSON.parse(response.body)
        expect(json_response['status']).to eq('success')
      end

      it 'returns winner information' do
        post '/winner_selection'
        json_response = JSON.parse(response.body)

        expect(json_response['winner']).to be_present
        expect(json_response['winner']['id']).to be_present
        expect(json_response['winner']['customer_name']).to be_present
        expect(json_response['winner']['pizza_type']).to be_present
        expect(json_response['winner']['size']).to be_present
        expect(json_response['winner']['order_date']).to be_present
      end

      it 'returns a valid customer name from existing orders' do
        post '/winner_selection'
        json_response = JSON.parse(response.body)

        winner_name = json_response['winner']['customer_name']
        expect([ 'Ana García', 'Carlos López', 'María Fernández' ]).to include(winner_name)
      end

      it 'returns valid pizza type from existing orders' do
        post '/winner_selection'
        json_response = JSON.parse(response.body)

        winner_pizza_type = json_response['winner']['pizza_type']
        expect([ 'margherita', 'pepperoni', 'vegetarian' ]).to include(winner_pizza_type)
      end

      it 'returns valid size from existing orders' do
        post '/winner_selection'
        json_response = JSON.parse(response.body)

        winner_size = json_response['winner']['size']
        expect([ 'small', 'medium', 'large' ]).to include(winner_size)
      end

      it 'returns the correct order data for the selected winner' do
        post '/winner_selection'
        json_response = JSON.parse(response.body)

        winner_id = json_response['winner']['id']
        actual_order = PizzaOrder.find(winner_id)

        expect(json_response['winner']['customer_name']).to eq(actual_order.customer_name)
        expect(json_response['winner']['pizza_type']).to eq(actual_order.pizza_type)
        expect(json_response['winner']['size']).to eq(actual_order.size)
      end

      it 'returns JSON content type' do
        post '/winner_selection'
        expect(response.content_type).to match(/application\/json/)
      end

      it 'can select different winners on multiple calls' do
        winners = []
        10.times do
          post '/winner_selection'
          json_response = JSON.parse(response.body)
          winners << json_response['winner']['customer_name']
        end

        # Should have some variety (not all the same winner every time)
        expect(winners.uniq.length).to be > 1
      end
    end

    context 'when there are no pizza orders' do
      before do
        PizzaOrder.destroy_all
      end

      it 'returns unprocessable entity status' do
        post '/winner_selection'
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it 'returns failed status in JSON' do
        post '/winner_selection'
        json_response = JSON.parse(response.body)
        expect(json_response['status']).to eq('failed')
      end

      it 'returns error message' do
        post '/winner_selection'
        json_response = JSON.parse(response.body)

        expect(json_response['errors']).to be_present
        expect(json_response['errors']).to include('No hay pedidos disponibles para seleccionar un ganador')
      end

      it 'does not include winner information when failed' do
        post '/winner_selection'
        json_response = JSON.parse(response.body)

        expect(json_response['winner']).to be_nil
      end

      it 'returns JSON content type even when failed' do
        post '/winner_selection'
        expect(response.content_type).to match(/application\/json/)
      end
    end

    context 'when service encounters an error' do
      before do
        allow_any_instance_of(WinnerSelectionService).to receive(:select_winner).and_return(false)
        allow_any_instance_of(WinnerSelectionService).to receive(:errors).and_return([ 'Database error' ])
      end

      it 'returns unprocessable entity status' do
        post '/winner_selection'
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it 'returns failed status with error messages' do
        post '/winner_selection'
        json_response = JSON.parse(response.body)

        expect(json_response['status']).to eq('failed')
        expect(json_response['errors']).to include('Database error')
      end
    end

    context 'integration with WinnerSelectionService' do
      let!(:order1) { PizzaOrder.create!(customer_name: 'Test Customer', pizza_type: 'margherita', size: 'medium') }

      it 'uses WinnerSelectionService to select winner' do
        service_instance = instance_double(WinnerSelectionService)
        allow(WinnerSelectionService).to receive(:new).and_return(service_instance)
        allow(service_instance).to receive(:select_winner).and_return(true)
        allow(service_instance).to receive(:winner).and_return(order1)

        post '/winner_selection'

        expect(WinnerSelectionService).to have_received(:new)
        expect(service_instance).to have_received(:select_winner)
      end

      it 'accesses winner data from service' do
        post '/winner_selection'
        json_response = JSON.parse(response.body)

        # The winner should be the only order we created
        expect(json_response['winner']['customer_name']).to eq('Test Customer')
        expect(json_response['winner']['pizza_type']).to eq('margherita')
        expect(json_response['winner']['size']).to eq('medium')
      end
    end

    context 'response format validation' do
      let!(:order1) { PizzaOrder.create!(customer_name: 'Format Test', pizza_type: 'pepperoni', size: 'large') }

      it 'returns properly formatted JSON response' do
        post '/winner_selection'

        expect { JSON.parse(response.body) }.not_to raise_error
      end

      it 'includes all required fields in winner object' do
        post '/winner_selection'
        json_response = JSON.parse(response.body)
        winner = json_response['winner']

        required_fields = [ 'id', 'customer_name', 'pizza_type', 'size', 'order_date' ]
        required_fields.each do |field|
          expect(winner).to have_key(field)
          expect(winner[field]).to be_present
        end
      end

      it 'formats order_date as ISO string' do
        post '/winner_selection'
        json_response = JSON.parse(response.body)
        order_date = json_response['winner']['order_date']

        expect { DateTime.parse(order_date) }.not_to raise_error
      end
    end
  end
end
