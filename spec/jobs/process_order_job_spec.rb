require 'rails_helper'

RSpec.describe ProcessOrderJob, type: :job do
  let(:pizza_order) { PizzaOrder.create!(customer_name: 'John Doe', pizza_type: 'margherita', size: 'medium') }

  describe '#perform' do
    context 'with valid order id' do
      it 'processes the order successfully' do
        expect(Rails.logger).to receive(:info).with("Procesando pedido #{pizza_order.id} para #{pizza_order.customer_name}")
        expect(Rails.logger).to receive(:info).with("Pedido #{pizza_order.id} completado")

        # Mock sleep to speed up tests
        allow_any_instance_of(described_class).to receive(:sleep)

        described_class.new.perform(pizza_order.id)
      end

      it 'logs the processing start' do
        allow_any_instance_of(described_class).to receive(:sleep)
        expect(Rails.logger).to receive(:info).with("Procesando pedido #{pizza_order.id} para #{pizza_order.customer_name}")
        expect(Rails.logger).to receive(:info).with("Pedido #{pizza_order.id} completado")

        described_class.new.perform(pizza_order.id)
      end

      it 'simulates cooking time' do
        expect_any_instance_of(described_class).to receive(:sleep).with(5)
        allow(Rails.logger).to receive(:info)

        described_class.new.perform(pizza_order.id)
      end
    end

    context 'with invalid order id' do
      it 'handles RecordNotFound gracefully' do
        invalid_id = 999999
        expect(Rails.logger).to receive(:error).with("No se encontró la orden con ID: #{invalid_id}")

        expect {
          described_class.new.perform(invalid_id)
        }.not_to raise_error
      end

      it 'does not process when order not found' do
        invalid_id = 999999
        allow(Rails.logger).to receive(:error)

        expect_any_instance_of(described_class).not_to receive(:sleep)
        described_class.new.perform(invalid_id)
      end
    end

    context 'when an unexpected error occurs' do
      before do
        allow(PizzaOrder).to receive(:find).and_raise(StandardError.new('Database connection failed'))
      end

      it 'logs the error and re-raises it' do
        expect(Rails.logger).to receive(:error).with('Error procesando orden 123: Database connection failed')

        expect {
          described_class.new.perform(123)
        }.to raise_error(StandardError, 'Database connection failed')
      end
    end
  end

  describe 'job enqueueing' do
    it 'is queued in the default queue' do
      expect(described_class.queue_name).to eq('default')
    end

    it 'can be enqueued' do
      expect {
        described_class.perform_later(pizza_order.id)
      }.to have_enqueued_job(described_class).with(pizza_order.id)
    end

    it 'can be performed immediately' do
      allow_any_instance_of(described_class).to receive(:sleep)
      allow(Rails.logger).to receive(:info)

      expect {
        described_class.perform_now(pizza_order.id)
      }.not_to raise_error
    end
  end

  describe 'error handling in real scenarios' do
    it 'handles nil order id' do
      expect(Rails.logger).to receive(:error).with('Error procesando orden : undefined method `id\' for nil:NilClass')

      expect {
        described_class.new.perform(nil)
      }.to raise_error(NoMethodError)
    end

    it 'handles string order id that exists' do
      allow_any_instance_of(described_class).to receive(:sleep)
      expect(Rails.logger).to receive(:info).twice

      described_class.new.perform(pizza_order.id.to_s)
    end
  end
end
