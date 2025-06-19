require "test_helper"

class PizzaOrdersControllerTest < ActionDispatch::IntegrationTest
  setup do
    @pizza_order = pizza_orders(:one)
  end

  # test 'debería crear un pedido de pizza' do
  #   post '/pizza_orders', params: { pizza_order: { customer_name: 'John', pizza_type: 'margherita', size: 'medium' } }
  #   assert_response :created
  #   assert_equal 'success', JSON.parse(response.body)['status']
  # end

  test "should get index" do
    get pizza_orders_url, as: :json
    assert_response :success
  end

  test "should create pizza_order" do
    assert_difference("PizzaOrder.count") do
      post pizza_orders_url, params: { pizza_order: { customer_name: @pizza_order.customer_name, pizza_type: @pizza_order.pizza_type, size: @pizza_order.size } }, as: :json
    end

    assert_response :created
  end

  test "should show pizza_order" do
    get pizza_order_url(@pizza_order), as: :json
    assert_response :success
  end

  test "should update pizza_order" do
    patch pizza_order_url(@pizza_order), params: { pizza_order: { customer_name: @pizza_order.customer_name, pizza_type: @pizza_order.pizza_type, size: @pizza_order.size } }, as: :json
    assert_response :success
  end

  test "should destroy pizza_order" do
    assert_difference("PizzaOrder.count", -1) do
      delete pizza_order_url(@pizza_order), as: :json
    end

    assert_response :no_content
  end
end
