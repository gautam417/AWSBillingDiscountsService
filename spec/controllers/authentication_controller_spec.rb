require 'rails_helper'

RSpec.describe AuthenticationController, type: :controller do
  describe 'POST #authenticate' do
    context 'with valid credentials' do
      before do
        post :authenticate, params: { username: 'admin', password: 'secret' }
      end

      it 'returns a JWT token' do
        expect(response).to have_http_status(:success)
        expect(JSON.parse(response.body)).to have_key('token')
      end
    end

    context 'with invalid credentials' do
      before do
        post :authenticate, params: { username: 'invalid_user', password: 'wrong_password' }
      end

      it 'returns unauthorized status' do
        expect(response).to have_http_status(:unauthorized)
      end

      it 'returns an error message' do
        expect(JSON.parse(response.body)['error']).to eq('Invalid username or password')
      end

      it 'logs failed authentication attempt' do
        expect(Rails.logger).to receive(:warn).with("Failed authentication attempt with username 'invalid_user'")
        post :authenticate, params: { username: 'invalid_user', password: 'wrong_password' }
      end
    end
  end
end
