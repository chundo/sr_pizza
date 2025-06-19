require 'rails_helper'

RSpec.describe '/pizza_orders', type: :request do
  # Clean up database before each test
  before(:each) do
    PizzaOrder.destroy_all
  end

  let(:valid_attributes) do
    {
      customer_name: 'John Doe',
      pizza_type: 'margherita',
      size: 'medium'
    }
  end

  let(:invalid_attributes) do
    {
      customer_name: '',
      pizza_type: 'invalid_type',
      size: 'invalid_size'
    }
  end

  let(:pizza_order) { PizzaOrder.create!(valid_attributes) }

  describe 'GET /pizza_orders' do
    it 'returns a success response' do
      PizzaOrder.create!(valid_attributes)
      get pizza_orders_url
      expect(response).to be_successful
      expect(response.content_type).to match(/application\/json/)
    end

    it 'returns all pizza orders' do
      order1 = PizzaOrder.create!(valid_attributes)
      order2 = PizzaOrder.create!(valid_attributes.merge(customer_name: 'Jane Doe'))

      get pizza_orders_url
      expect(response).to be_successful

      json_response = JSON.parse(response.body)
      expect(json_response.length).to eq(2)
      expect(json_response.map { |order| order['id'] }).to include(order1.id, order2.id)
    end

    it 'returns empty array when no orders exist' do
      get pizza_orders_url
      expect(response).to be_successful

      json_response = JSON.parse(response.body)
      expect(json_response).to eq([])
    end
  end

  describe 'GET /pizza_orders/:id' do
    it 'returns a success response' do
      get pizza_order_url(pizza_order)
      expect(response).to be_successful
      expect(response.content_type).to match(/application\/json/)
    end

    it 'returns the correct pizza order' do
      get pizza_order_url(pizza_order)
      expect(response).to be_successful

      json_response = JSON.parse(response.body)
      expect(json_response['id']).to eq(pizza_order.id)
      expect(json_response['customer_name']).to eq(pizza_order.customer_name)
      expect(json_response['pizza_type']).to eq(pizza_order.pizza_type)
      expect(json_response['size']).to eq(pizza_order.size)
    end

    it 'returns 404 when pizza order not found' do
      get pizza_order_url(999999)
      expect(response).to have_http_status(:not_found)
    end
  end

  describe 'POST /pizza_orders' do
    context 'with valid parameters' do
      it 'creates a new PizzaOrder successfully' do
        expect {
          post pizza_orders_url, params: { pizza_order: valid_attributes }
        }.to change(PizzaOrder, :count).by(1)

        expect(response).to have_http_status(:created)
        json_response = JSON.parse(response.body)
        expect(json_response['status']).to eq('success')
      end

      it 'returns success status' do
        post pizza_orders_url, params: { pizza_order: valid_attributes }
        expect(response).to have_http_status(:created)
        expect(response.content_type).to match(/application\/json/)
      end

      it 'enqueues ProcessOrderJob' do
        expect {
          post pizza_orders_url, params: { pizza_order: valid_attributes }
        }.to have_enqueued_job(ProcessOrderJob)
      end
    end

    context 'with invalid parameters' do
      it 'does not create a pizza order' do
        expect {
          post pizza_orders_url, params: { pizza_order: { customer_name: '' } }
        }.not_to change(PizzaOrder, :count)
      end

      it 'returns unprocessable entity status' do
        post pizza_orders_url, params: { pizza_order: { customer_name: '' } }
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it 'returns error messages' do
        post pizza_orders_url, params: { pizza_order: { customer_name: '' } }

        json_response = JSON.parse(response.body)
        expect(json_response['status']).to eq('failed')
        expect(json_response['errors']).to be_present
        expect(json_response['errors']).to be_an(Array)
      end

      it 'handles invalid enum values' do
        invalid_params = {
          customer_name: 'Test User',
          pizza_type: 'invalid_pizza',
          size: 'medium'
        }

        post pizza_orders_url, params: { pizza_order: invalid_params }
        expect(response).to have_http_status(:unprocessable_entity)

        json_response = JSON.parse(response.body)
        expect(json_response['status']).to eq('failed')
        expect(json_response['errors']).to be_present
      end
    end
  end

  describe 'PUT /pizza_orders/:id' do
    context 'with valid parameters' do
      let(:new_attributes) do
        {
          customer_name: 'Jane Smith',
          pizza_type: 'pepperoni',
          size: 'large'
        }
      end

      it 'updates the requested pizza order' do
        put pizza_order_url(pizza_order), params: { pizza_order: new_attributes }
        pizza_order.reload

        expect(pizza_order.customer_name).to eq('Jane Smith')
        expect(pizza_order.pizza_type).to eq('pepperoni')
        expect(pizza_order.size).to eq('large')
      end

      it 'returns a success response' do
        put pizza_order_url(pizza_order), params: { pizza_order: new_attributes }
        expect(response).to be_successful
        expect(response.content_type).to match(/application\/json/)
      end

      it 'returns the updated pizza order' do
        put pizza_order_url(pizza_order), params: { pizza_order: new_attributes }

        json_response = JSON.parse(response.body)
        expect(json_response['customer_name']).to eq('Jane Smith')
        expect(json_response['pizza_type']).to eq('pepperoni')
        expect(json_response['size']).to eq('large')
      end
    end

    context 'with invalid parameters' do
      it 'returns unprocessable entity status' do
        put pizza_order_url(pizza_order), params: { pizza_order: { customer_name: '' } }
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it 'returns error messages' do
        put pizza_order_url(pizza_order), params: { pizza_order: { customer_name: '' } }

        json_response = JSON.parse(response.body)
        expect(json_response).to have_key('customer_name')
        expect(json_response['customer_name']).to include("can't be blank")
      end

      it 'does not update the pizza order' do
        original_name = pizza_order.customer_name
        put pizza_order_url(pizza_order), params: { pizza_order: { customer_name: '' } }
        pizza_order.reload

        expect(pizza_order.customer_name).to eq(original_name)
      end

      it 'handles invalid enum values' do
        expect {
          put pizza_order_url(pizza_order), params: { pizza_order: { pizza_type: 'invalid_pizza' } }
        }.to raise_error(ArgumentError, "'invalid_pizza' is not a valid pizza_type")
      end
    end

    it 'returns 404 when pizza order not found' do
      put pizza_order_url(999999), params: { pizza_order: valid_attributes }
      expect(response).to have_http_status(:not_found)
    end
  end

  describe 'DELETE /pizza_orders/:id' do
    it 'destroys the requested pizza order' do
      pizza_order_to_delete = PizzaOrder.create!(valid_attributes)

      expect {
        delete pizza_order_url(pizza_order_to_delete)
      }.to change(PizzaOrder, :count).by(-1)
    end

    it 'returns a success response' do
      delete pizza_order_url(pizza_order)
      expect(response).to be_successful
    end

    it 'returns 404 when pizza order not found' do
      delete pizza_order_url(999999)
      expect(response).to have_http_status(:not_found)
    end
  end

  describe 'parameter filtering' do
    it 'only allows permitted parameters' do
      malicious_params = {
        customer_name: 'Test User',
        pizza_type: 'margherita',
        size: 'medium',
        admin: true,
        created_at: 1.year.ago
      }

      post pizza_orders_url, params: { pizza_order: malicious_params }
      expect(response).to have_http_status(:created)

      created_order = PizzaOrder.last
      expect(created_order.customer_name).to eq('Test User')
      expect(created_order.pizza_type).to eq('margherita')
      expect(created_order.size).to eq('medium')
      # Verify that unauthorized params were not set
      expect(created_order.created_at).to be_within(5.seconds).of(Time.current)
    end
  end

  describe 'content type validation' do
    it 'returns JSON content type for all successful responses' do
      # Index
      get pizza_orders_url
      expect(response.content_type).to match(/application\/json/)

      # Show
      get pizza_order_url(pizza_order)
      expect(response.content_type).to match(/application\/json/)

      # Create
      post pizza_orders_url, params: { pizza_order: valid_attributes }
      expect(response.content_type).to match(/application\/json/)

      # Update
      put pizza_order_url(pizza_order), params: { pizza_order: valid_attributes }
      expect(response.content_type).to match(/application\/json/)
    end
  end

  describe 'edge cases' do
    it 'handles empty request body gracefully' do
      post pizza_orders_url, params: {}
      expect(response).to have_http_status(:bad_request)
    end

    it 'handles missing pizza_order parameter' do
      post pizza_orders_url, params: { other_param: 'value' }
      expect(response).to have_http_status(:bad_request)
    end

    it 'handles very long customer names' do
      long_name = 'A' * 1000
      post pizza_orders_url, params: {
        pizza_order: valid_attributes.merge(customer_name: long_name)
      }
      expect(response).to have_http_status(:created)

      created_order = PizzaOrder.last
      expect(created_order.customer_name).to eq(long_name)
    end
  end
end
