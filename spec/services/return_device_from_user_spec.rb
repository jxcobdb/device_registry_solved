# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ReturnDeviceFromUser do
  let(:user) { User.create!(email: "user@example.com", password: "123456") }
  let(:other_user) { User.create!(email: "other@example.com", password: "123456") }
  let(:device) { Device.create!(serial_number: "XYZ123", user: user) }

  subject { described_class.new(user: user, device: device).call }

  context "when both user and device exist and device belongs to user" do
    it "returns the device and logs it in assignment history" do
      result = subject

      expect(result.success?).to be true
      expect(device.reload.user).to be_nil
      expect(AssignmentHistory.last.action).to eq("returned")
    end
  end

  context "when user is nil" do
    let(:user) { nil }

    it "fails with appropriate error" do
      result = subject

      expect(result.success?).to be false
      expect(result.error).to eq("User does not exist")
    end
  end

  context "when device is nil" do
    let(:device) { nil }

    it "fails with appropriate error" do
      result = subject

      expect(result.success?).to be false
      expect(result.error).to eq("Device does not exist")
    end
  end

  context "when device belongs to another user" do
    let(:device) { Device.create!(serial_number: "ABC999", user: other_user) }

    it "fails with appropriate error" do
      result = subject

      expect(result.success?).to be false
      expect(result.error).to eq("Device does not belong to the user")
    end
  end

  context "when device is unassigned" do
    let(:device) { Device.create!(serial_number: "UNBOUND", user: nil) }

    it "fails with appropriate error" do
      result = subject

      expect(result.success?).to be false
      expect(result.error).to eq("Device does not belong to the user")
    end
  end
end

