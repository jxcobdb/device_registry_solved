# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ReturnDeviceFromUser do
  let(:user) { User.create!(email: "test@example.com", password: "123456") }
  let(:device) { Device.create!(serial_number: "XYZ123", user: user) }

  it "allows user to return their own device" do
    result = described_class.new(user: user, device: device).call

    expect(result.success?).to be true
    expect(device.reload.user).to be_nil
    expect(AssignmentHistory.last.action).to eq("returned")
  end
end

