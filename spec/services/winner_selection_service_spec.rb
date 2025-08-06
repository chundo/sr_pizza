require 'rails_helper'

RSpec.describe WinnerSelectionService, type: :service do
  describe '#initialize' do
    it 'initializes with nil winner and empty errors' do
      service = described_class.new
      expect(service.winner).to be_nil
      expect(service.errors).to eq([])
    end
  end

  describe '#select_winner' do
    context 'when there are pizza orders' do
      let!(:order1) { PizzaOrder.create!(customer_name: 'Ana García', pizza_type: 'margherita', size: 'medium') }
      let!(:order2) { PizzaOrder.create!(customer_name: 'Carlos López', pizza_type: 'pepperoni', size: 'large') }
      let!(:order3) { PizzaOrder.create!(customer_name: 'María Fernández', pizza_type: 'vegetarian', size: 'small') }

      it 'returns true on success' do
        service = described_class.new
        result = service.select_winner

        expect(result).to be true
      end

      it 'selects a winner from existing customers' do
        service = described_class.new
        service.select_winner

        expect(service.winner).to be_a(PizzaOrder)
        expect(service.winner).to be_persisted
        expect([ 'Ana García', 'Carlos López', 'María Fernández' ]).to include(service.winner.customer_name)
      end

      it 'clears errors on success' do
        service = described_class.new
        service.select_winner

        expect(service.errors).to be_empty
      end

      it 'selects different winners on multiple calls (randomness test)' do
        # Run multiple times to test randomness (though this may occasionally fail due to randomness)
        winners = []
        20.times do
          service = described_class.new
          service.select_winner
          winners << service.winner.customer_name
        end

        # Should have some variety (not all the same winner every time)
        expect(winners.uniq.length).to be > 1
      end
    end

    context 'when a customer has multiple orders' do
      let!(:order1) { PizzaOrder.create!(customer_name: 'Ana García', pizza_type: 'margherita', size: 'medium') }
      let!(:order2) { PizzaOrder.create!(customer_name: 'Ana García', pizza_type: 'pepperoni', size: 'large') }
      let!(:order3) { PizzaOrder.create!(customer_name: 'Carlos López', pizza_type: 'vegetarian', size: 'small') }

      it 'selects unique customers only once' do
        # Ana García has 2 orders, Carlos López has 1 order
        # But each customer should have equal chance to win
        winners = []
        30.times do
          service = described_class.new
          service.select_winner
          winners << service.winner.customer_name
        end

        # Should include both customers despite Ana having more orders
        expect(winners).to include('Ana García')
        expect(winners).to include('Carlos López')

        # Ana García should not be significantly more likely to win just because she has more orders
        ana_wins = winners.count('Ana García')
        carlos_wins = winners.count('Carlos López')

        # With 30 runs and equal probability, we expect roughly 15-15, but allow for randomness
        # If selection was biased by order count, Ana would have ~20 wins vs Carlos' ~10
        expect((ana_wins - carlos_wins).abs).to be < 10  # Allow reasonable randomness variation
      end

      it 'returns the first order when a customer has multiple orders' do
        service = described_class.new
        service.select_winner

        if service.winner.customer_name == 'Ana García'
          # Should return the first order for Ana García (the margherita one)
          expect(service.winner.id).to eq(order1.id)
        end
      end
    end

    context 'when there are no pizza orders' do
      it 'returns false when no orders exist' do
        service = described_class.new
        result = service.select_winner

        expect(result).to be false
      end

      it 'does not set a winner when no orders exist' do
        service = described_class.new
        service.select_winner

        expect(service.winner).to be_nil
      end

      it 'populates errors when no orders exist' do
        service = described_class.new
        service.select_winner

        expect(service.errors).to include('No hay pedidos disponibles para seleccionar un ganador')
      end
    end

    context 'when an exception is raised' do
      before do
        allow(PizzaOrder).to receive(:all).and_raise(StandardError.new('Database error'))
      end

      it 'handles exceptions gracefully' do
        service = described_class.new

        expect { service.select_winner }.not_to raise_error
      end

      it 'returns false when exception occurs' do
        service = described_class.new

        result = service.select_winner
        expect(result).to be false
      end

      it 'populates errors with exception message' do
        service = described_class.new
        service.select_winner

        expect(service.errors).to include('Error interno del servidor: Database error')
      end

      it 'logs the error' do
        service = described_class.new

        expect(Rails.logger).to receive(:error).with('Error en WinnerSelectionService: Database error')
        expect(Rails.logger).to receive(:error).with(kind_of(String)) # backtrace

        service.select_winner
      end
    end
  end

  describe 'integration with existing data' do
    context 'with seeded data' do
      # Assuming the database has seeded data from the seeds file
      it 'can select from actual seeded customers' do
        # Only test if there's actual seeded data
        if PizzaOrder.count > 0
          service = described_class.new
          result = service.select_winner

          expect(result).to be true
          expect(service.winner).to be_present
          expect(service.winner.customer_name).to be_present
        end
      end
    end
  end

  describe 'error handling edge cases' do
    context 'when database is empty after orders are deleted' do
      it 'handles empty database gracefully' do
        # Ensure database is empty
        PizzaOrder.destroy_all

        service = described_class.new
        result = service.select_winner

        expect(result).to be false
        expect(service.winner).to be_nil
        expect(service.errors).to include('No hay pedidos disponibles para seleccionar un ganador')
      end
    end
  end

  describe 'winner selection fairness' do
    let!(:customers) do
      [
        PizzaOrder.create!(customer_name: 'Customer 1', pizza_type: 'margherita', size: 'small'),
        PizzaOrder.create!(customer_name: 'Customer 2', pizza_type: 'pepperoni', size: 'medium'),
        PizzaOrder.create!(customer_name: 'Customer 3', pizza_type: 'vegetarian', size: 'large'),
        PizzaOrder.create!(customer_name: 'Customer 4', pizza_type: 'margherita', size: 'medium'),
        PizzaOrder.create!(customer_name: 'Customer 5', pizza_type: 'pepperoni', size: 'small')
      ]
    end

    it 'gives each customer roughly equal chance to win' do
      winners = {}
      100.times do
        service = described_class.new
        service.select_winner
        winner_name = service.winner.customer_name
        winners[winner_name] = (winners[winner_name] || 0) + 1
      end

      # With 5 customers and 100 runs, each should get roughly 20 wins
      # Allow for reasonable variance in randomness
      winners.each_value do |count|
        expect(count).to be_between(5, 35) # Allow wide variance for randomness
      end

      # All 5 customers should win at least once
      expect(winners.keys.length).to eq(5)
    end
  end
end
