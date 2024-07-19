require 'rails_helper'

RSpec.describe CostsController, type: :controller do
  before do
    allow(LineItem).to receive(:total_unblended_cost).and_return(100.0)
    allow(LineItem).to receive(:total_discounted_cost).and_return(88.0)
    allow(LineItem).to receive(:blended_discount_rate).and_return(66.67)
    allow(controller).to receive(:authenticate_request!).and_return(true) # Bypass authentication for testing
  end

  describe 'GET #undiscounted' do
    it 'returns the total unblended cost for a given service' do
      get :undiscounted, params: { service: 'AmazonS3' }
      expect(response).to have_http_status(:success)
      json_response = JSON.parse(response.body)
      expect(json_response['service']).to eq('AmazonS3')
      expect(json_response['undiscounted_cost']).to eq(100.0)
    end
  end

  describe 'GET #discounted' do
    it 'returns the total discounted cost for a given service' do
      get :discounted, params: { service: 'AmazonS3' }
      expect(response).to have_http_status(:success)
      json_response = JSON.parse(response.body)
      expect(json_response['service']).to eq('AmazonS3')
      expect(json_response['discounted_cost']).to eq(88.0) # 12% discount
    end
  end

  describe 'GET #blended_rate' do
    it 'returns the blended discount rate' do
      get :blended_rate
      expect(response).to have_http_status(:success)
      json_response = JSON.parse(response.body)
      expect(json_response['blended_rate']).to eq(66.67) # Mocked rate
    end
  end
end