# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AssignDeviceToUser do
  let(:requesting_user) { create(:user) }
  let(:target_user) { requesting_user } # domyślnie przypisuje do siebie
  let(:device) { create(:device, user: nil) }

  subject(:service_call) do
    described_class.new(
      requesting_user: requesting_user,
      user: target_user,
      device: device
    ).call
  end

  context 'when all inputs are valid' do
    it 'assigns the device to the user and creates assignment history' do
      expect { service_call }.to change { AssignmentHistory.count }.by(1)
      expect(device.reload.user).to eq(requesting_user)
      expect(service_call).to be_success
    end
  end

  context 'when user does not exist' do
    let(:target_user) { nil }

    it 'returns failure' do
      expect(service_call).not_to be_success
      expect(service_call.error).to eq("User does not exist")
    end
  end

  context 'when device does not exist' do
    let(:device) { nil }

    it 'returns failure' do
      expect(service_call).not_to be_success
      expect(service_call.error).to eq("Device does not exist")
    end
  end

  context 'when assigning to another user' do
    let(:target_user) { create(:user) } # różny od requesting_user

    it 'returns failure' do
      expect(service_call).not_to be_success
      expect(service_call.error).to eq("You are not allowed to assign device to another user")
    end
  end

  context 'when device is already assigned to this user' do
    let(:device) { create(:device, user: requesting_user) }

    it 'returns failure' do
      expect(service_call).not_to be_success
      expect(service_call.error).to eq("User already has this device")
    end
  end

  context 'when device is assigned to another user' do
    let(:device) { create(:device, user: create(:user)) }

    it 'returns failure' do
      expect(service_call).not_to be_success
      expect(service_call.error).to eq("Device is already assigned to another user")
    end
  end

  context 'when device has already been returned by user' do
    before do
      AssignmentHistory.create!(user: requesting_user, device: device, action: "returned")
    end

    it 'returns failure' do
      expect(service_call).not_to be_success
      expect(service_call.error).to eq("You have returned this device before and can't reassign it")
    end
  end
end
