require 'rails_helper'

RSpec.describe PizzaOrder, type: :model do
  describe 'validations' do
    it 'is valid with valid attributes' do
      pizza_order = PizzaOrder.new(
        customer_name: 'John Doe',
        pizza_type: 'margherita',
        size: 'medium'
      )
      expect(pizza_order).to be_valid
    end

    describe 'customer_name' do
      it 'is required' do
        pizza_order = PizzaOrder.new(pizza_type: 'margherita', size: 'medium')
        expect(pizza_order).not_to be_valid
        expect(pizza_order.errors[:customer_name]).to include("can't be blank")
      end

      it 'is valid when present' do
        pizza_order = PizzaOrder.new(
          customer_name: 'Jane Smith',
          pizza_type: 'pepperoni',
          size: 'large'
        )
        expect(pizza_order).to be_valid
      end
    end

    describe 'pizza_type' do
      it 'is required' do
        pizza_order = PizzaOrder.new(customer_name: 'John Doe', size: 'medium')
        expect(pizza_order).not_to be_valid
        expect(pizza_order.errors[:pizza_type]).to include("can't be blank")
      end

      it 'accepts valid pizza types' do
        PizzaOrder::PIZZA_TYPES.each do |pizza_type|
          pizza_order = PizzaOrder.new(
            customer_name: 'John Doe',
            pizza_type: pizza_type,
            size: 'medium'
          )
          expect(pizza_order).to be_valid, "Expected #{pizza_type} to be valid"
        end
      end

      it 'rejects invalid pizza types' do
        expect {
          PizzaOrder.new(
            customer_name: 'John Doe',
            pizza_type: 'hawaiian',
            size: 'medium'
          )
        }.to raise_error(ArgumentError, "'hawaiian' is not a valid pizza_type")
      end
    end

    describe 'size' do
      it 'is required' do
        pizza_order = PizzaOrder.new(customer_name: 'John Doe', pizza_type: 'margherita')
        expect(pizza_order).not_to be_valid
        expect(pizza_order.errors[:size]).to include("can't be blank")
      end

      it 'accepts valid sizes' do
        PizzaOrder::SIZES.each do |size|
          pizza_order = PizzaOrder.new(
            customer_name: 'John Doe',
            pizza_type: 'vegetarian',
            size: size
          )
          expect(pizza_order).to be_valid, "Expected #{size} to be valid"
        end
      end

      it 'rejects invalid sizes' do
        expect {
          PizzaOrder.new(
            customer_name: 'John Doe',
            pizza_type: 'margherita',
            size: 'extra_large'
          )
        }.to raise_error(ArgumentError, "'extra_large' is not a valid size")
      end
    end
  end

  describe 'enums' do
    describe 'pizza_type enum' do
      it 'defines the correct pizza type values' do
        expect(PizzaOrder.pizza_types).to eq({
          'margherita' => 'margherita',
          'pepperoni' => 'pepperoni',
          'vegetarian' => 'vegetarian'
        })
      end

      it 'provides query methods for pizza types' do
        margherita_order = PizzaOrder.new(pizza_type: 'margherita')
        expect(margherita_order.margherita?).to be true
        expect(margherita_order.pepperoni?).to be false
        expect(margherita_order.vegetarian?).to be false
      end

      it 'allows setting pizza type using enum methods' do
        pizza_order = PizzaOrder.new(
          customer_name: 'John Doe',
          size: 'medium'
        )
        pizza_order.pepperoni!
        expect(pizza_order.pizza_type).to eq('pepperoni')
        expect(pizza_order.pepperoni?).to be true
      end
    end

    describe 'size enum' do
      it 'defines the correct size values' do
        expect(PizzaOrder.sizes).to eq({
          'small' => 'small',
          'medium' => 'medium',
          'large' => 'large'
        })
      end

      it 'provides query methods for sizes' do
        large_order = PizzaOrder.new(size: 'large')
        expect(large_order.large?).to be true
        expect(large_order.small?).to be false
        expect(large_order.medium?).to be false
      end

      it 'allows setting size using enum methods' do
        pizza_order = PizzaOrder.new(
          customer_name: 'Jane Doe',
          pizza_type: 'margherita'
        )
        pizza_order.small!
        expect(pizza_order.size).to eq('small')
        expect(pizza_order.small?).to be true
      end
    end
  end

  describe 'constants' do
    it 'defines PIZZA_TYPES correctly' do
      expect(PizzaOrder::PIZZA_TYPES).to eq(%w[margherita pepperoni vegetarian])
      expect(PizzaOrder::PIZZA_TYPES).to be_frozen
    end

    it 'defines SIZES correctly' do
      expect(PizzaOrder::SIZES).to eq(%w[small medium large])
      expect(PizzaOrder::SIZES).to be_frozen
    end
  end

  describe 'database operations' do
    it 'can be saved to the database' do
      pizza_order = PizzaOrder.new(
        customer_name: 'Alice Johnson',
        pizza_type: 'margherita',
        size: 'large'
      )
      expect { pizza_order.save! }.not_to raise_error
      expect(pizza_order.persisted?).to be true
    end

    it 'has timestamps when saved' do
      pizza_order = PizzaOrder.create!(
        customer_name: 'Bob Wilson',
        pizza_type: 'pepperoni',
        size: 'medium'
      )
      expect(pizza_order.created_at).to be_present
      expect(pizza_order.updated_at).to be_present
    end

    it 'can be found after creation' do
      pizza_order = PizzaOrder.create!(
        customer_name: 'Carol Davis',
        pizza_type: 'vegetarian',
        size: 'small'
      )
      found_order = PizzaOrder.find(pizza_order.id)
      expect(found_order.customer_name).to eq('Carol Davis')
      expect(found_order.pizza_type).to eq('vegetarian')
      expect(found_order.size).to eq('small')
    end
  end

  describe 'scopes and queries' do
    before do
      PizzaOrder.create!(customer_name: 'Test 1', pizza_type: 'margherita', size: 'small')
      PizzaOrder.create!(customer_name: 'Test 2', pizza_type: 'pepperoni', size: 'medium')
      PizzaOrder.create!(customer_name: 'Test 3', pizza_type: 'vegetarian', size: 'large')
      PizzaOrder.create!(customer_name: 'Test 4', pizza_type: 'margherita', size: 'large')
    end

    it 'can query by pizza type' do
      margherita_orders = PizzaOrder.where(pizza_type: 'margherita')
      expect(margherita_orders.count).to eq(2)
    end

    it 'can query by size' do
      large_orders = PizzaOrder.where(size: 'large')
      expect(large_orders.count).to eq(2)
    end

    it 'can use enum scopes' do
      margherita_orders = PizzaOrder.margherita
      expect(margherita_orders.count).to eq(2)

      large_orders = PizzaOrder.large
      expect(large_orders.count).to eq(2)
    end
  end
end
