# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DevicesController, type: :controller do
  let(:api_key) { create(:api_key) }
  let(:user) { api_key.bearer }


  describe 'POST #assign' do
    subject(:assign) do
      post :assign,
           params: { new_owner_id: new_owner_id, device: { serial_number: '123456' } },
           session: { token: user.api_keys.first.token }
    end
    context 'when the user is authenticated' do
      context 'when user assigns a device to another user' do
        let(:new_owner_id) { create(:user).id }

        it 'returns an unauthorized response' do
          assign
          expect(response.code).to eq("422")
          expect(JSON.parse(response.body)).to eq({ 'error' => 'Unauthorized' })
        end
      end

      context 'when user assigns a device to self' do
        let!(:device) { create(:device, serial_number: '123456') }
        let(:new_owner_id) { user.id }

        it 'returns a success response' do
          assign
          expect(response).to be_successful
        end
      end
    end

    context 'when the user is not authenticated' do
      it 'returns an unauthorized response' do
        post :assign
        expect(response).to be_unauthorized
      end
    end
  end

  describe 'POST #unassign' do
    let(:api_key) { create(:api_key) }
    let(:user) { api_key.bearer }
    let!(:device) { create(:device, serial_number: 'SN-UNASSIGN', user: user) }

    subject(:unassign) do
      post :unassign,
           params: { serial_number: device.serial_number },
           session: { token: user.api_keys.first.token }
    end

    context 'when the user is authenticated' do
      context 'when user unassigns their own device' do
        it 'returns a success response' do
          unassign
          expect(response).to be_successful
          expect(device.reload.user).to be_nil
        end
      end

      context 'when user tries to unassign a device they do not own' do
        let(:other_user) { create(:user) }
        let!(:device) { create(:device, serial_number: 'SN-OTHER', user: other_user) }

        it 'returns an unauthorized response' do
          post :unassign,
               params: { serial_number: device.serial_number },
               session: { token: user.api_keys.first.token }
          expect(response.code).to eq("422")
          expect(JSON.parse(response.body)).to eq({ 'error' => 'Unauthorized' })
        end
      end

      context 'when device does not exist' do
        it 'returns an error response' do
          post :unassign,
               params: { serial_number: 'NONEXISTENT' },
               session: { token: user.api_keys.first.token }
          expect(response.code).to eq("422")
          expect(JSON.parse(response.body)).to eq({ 'error' => 'Device does not exist' })
        end
      end
    end

    context 'when the user is not authenticated' do
      it 'returns an unauthorized response' do
        post :unassign, params: { serial_number: 'SN-UNASSIGN' }
        expect(response).to be_unauthorized
      end
    end
  end
end
