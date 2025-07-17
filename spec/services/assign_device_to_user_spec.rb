# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AssignDeviceToUser do
  let(:user) { User.create!(email: "test@example.com", password: "123456") }
  let(:device) { Device.create!(serial_number: "XYZ123") }

  it "assigns device to user if allowed" do
    result = described_class.new(user: user, device: device).call

    expect(result.success?).to be true
    expect(device.reload.user).to eq(user)
  end
end