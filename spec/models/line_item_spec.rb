require 'rails_helper'

RSpec.describe LineItem, type: :model do
  before do
    allow(LineItem).to receive(:by_service).and_return(LineItem)
    allow(LineItem).to receive(:usage_items).and_return(LineItem)
  end

  describe '.total_unblended_cost' do
    it 'calculates the total unblended cost for a given service' do
      allow(LineItem).to receive(:sum).with(:line_item_unblended_cost).and_return(300.0)
      expect(LineItem.total_unblended_cost('AmazonS3')).to eq(300.0)
    end
  end

  describe '.total_discounted_cost' do
    it 'calculates the total discounted cost for a given service' do
      service = 'AmazonS3'
      allow(LineItem).to receive(:sum).with("line_item_unblended_cost * (1 - 0.12)").and_return(264.0)
      expect(LineItem.total_discounted_cost(service)).to eq(264.0) # 12% discount for AmazonS3
    end
  end

  describe '.blended_discount_rate' do
    it 'calculates the blended discount rate' do
      services_and_discounts = {
        'AmazonS3' => 0.12,
        'AmazonEC2' => 0.50,
        'AWSDataTransfer' => 0.30,
        'AWSGlue' => 0.05,
        'AmazonGuardDuty' => 0.75
      }

      # Mock the total unblended cost
      allow(LineItem).to receive(:total_unblended_cost).and_return(300.0)

      # Mock total discounted costs for each service
      services_and_discounts.each do |service, discount|
        allow(LineItem).to receive(:total_discounted_cost).with(service).and_return(200.0 * (1 - discount))
      end

      expect(LineItem.blended_discount_rate).to eq(43.73) 
    end
  end
end
