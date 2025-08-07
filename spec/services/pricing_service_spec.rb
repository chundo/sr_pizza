require 'rails_helper'

RSpec.describe PricingService, type: :service do
  describe '#initialize' do
    it 'calculates pricing for valid pizza type and size' do
      service = PricingService.new('margherita', 'medium')
      
      expect(service.pizza_type).to eq('margherita')
      expect(service.size).to eq('medium')
      expect(service.vat_rate).to eq(0.19)
      expect(service.base_price).to eq(16.00)
      expect(service.vat_amount).to eq(3.04)
      expect(service.total_price).to eq(19.04)
    end

    it 'accepts custom VAT rate' do
      service = PricingService.new('pepperoni', 'large', vat_rate: 0.21)
      
      expect(service.vat_rate).to eq(0.21)
      expect(service.base_price).to eq(22.00)
      expect(service.vat_amount).to eq(4.62)
      expect(service.total_price).to eq(26.62)
    end

    it 'handles invalid pizza type gracefully' do
      service = PricingService.new('invalid', 'medium')
      
      expect(service.base_price).to be_nil
      expect(service.vat_amount).to be_nil
      expect(service.total_price).to be_nil
    end

    it 'handles invalid size gracefully' do
      service = PricingService.new('margherita', 'invalid')
      
      expect(service.base_price).to be_nil
      expect(service.vat_amount).to be_nil
      expect(service.total_price).to be_nil
    end
  end

  describe '.calculate_for_order' do
    it 'returns a pricing service instance' do
      service = PricingService.calculate_for_order('vegetarian', 'small')
      
      expect(service).to be_a(PricingService)
      expect(service.base_price).to eq(13.00)
      expect(service.vat_amount).to eq(2.47)
      expect(service.total_price).to eq(15.47)
    end

    it 'accepts custom VAT rate' do
      service = PricingService.calculate_for_order('margherita', 'large', vat_rate: 0.15)
      
      expect(service.vat_rate).to eq(0.15)
      expect(service.vat_amount).to eq(3.00)
      expect(service.total_price).to eq(23.00)
    end
  end

  describe '#to_h' do
    it 'returns a hash with pricing information' do
      service = PricingService.new('pepperoni', 'medium')
      result = service.to_h
      
      expect(result).to eq({
        base_price: 18.00,
        vat_rate: 0.19,
        vat_amount: 3.42,
        total_price: 21.42
      })
    end

    it 'returns hash with nil values for invalid inputs' do
      service = PricingService.new('invalid', 'invalid')
      result = service.to_h
      
      expect(result[:base_price]).to be_nil
      expect(result[:vat_amount]).to be_nil
      expect(result[:total_price]).to be_nil
      expect(result[:vat_rate]).to eq(0.19)
    end
  end

  describe 'pricing constants' do
    it 'defines PRICES correctly' do
      expect(PricingService::PRICES).to be_a(Hash)
      expect(PricingService::PRICES).to be_frozen
      expect(PricingService::PRICES.keys).to match_array(%w[margherita pepperoni vegetarian])
      
      PricingService::PRICES.each do |pizza_type, prices|
        expect(prices.keys).to match_array(%w[small medium large])
        prices.each do |size, price|
          expect(price).to be_a(Numeric)
          expect(price).to be > 0
        end
      end
    end

    it 'defines DEFAULT_VAT_RATE correctly' do
      expect(PricingService::DEFAULT_VAT_RATE).to eq(0.19)
    end
  end

  describe 'comprehensive pricing tests' do
    let(:test_cases) do
      [
        { pizza_type: 'margherita', size: 'small', base: 12.00, vat: 2.28, total: 14.28 },
        { pizza_type: 'margherita', size: 'medium', base: 16.00, vat: 3.04, total: 19.04 },
        { pizza_type: 'margherita', size: 'large', base: 20.00, vat: 3.80, total: 23.80 },
        { pizza_type: 'pepperoni', size: 'small', base: 14.00, vat: 2.66, total: 16.66 },
        { pizza_type: 'pepperoni', size: 'medium', base: 18.00, vat: 3.42, total: 21.42 },
        { pizza_type: 'pepperoni', size: 'large', base: 22.00, vat: 4.18, total: 26.18 },
        { pizza_type: 'vegetarian', size: 'small', base: 13.00, vat: 2.47, total: 15.47 },
        { pizza_type: 'vegetarian', size: 'medium', base: 17.00, vat: 3.23, total: 20.23 },
        { pizza_type: 'vegetarian', size: 'large', base: 21.00, vat: 3.99, total: 24.99 }
      ]
    end

    it 'calculates correct pricing for all combinations' do
      test_cases.each do |test_case|
        service = PricingService.new(test_case[:pizza_type], test_case[:size])
        
        expect(service.base_price).to eq(test_case[:base]), 
          "Base price mismatch for #{test_case[:pizza_type]} #{test_case[:size]}"
        expect(service.vat_amount).to eq(test_case[:vat]), 
          "VAT amount mismatch for #{test_case[:pizza_type]} #{test_case[:size]}"
        expect(service.total_price).to eq(test_case[:total]), 
          "Total price mismatch for #{test_case[:pizza_type]} #{test_case[:size]}"
      end
    end
  end
end