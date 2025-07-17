# frozen_string_literal: true

class AssignDeviceToUser
  def initialize(user:, device:)
    @user = user
    @device = device
  end

  def call
    return failure("User does not exist") unless user.present?
    return failure("Device does not exist") unless device.present?
    return failure("User already has this device") if user.devices.exists?(device.id)
    return failure("Device is already assigned to another user") if assigned_to_other_user?
    return failure("You have returned this device before and can't reassign it") if previously_returned?

    ActiveRecord::Base.transaction do
      device.update!(user: user)
      AssignmentHistory.create!(user: user, device: device, action: :assigned)
    end

    success
  end

  private

  attr_reader :user, :device

  def assigned_to_other_user?
    device.user.present? && device.user != user
  end

  def previously_returned?
    AssignmentHistory.exists?(user: user, device: device, action: "returned")
  end

  def success
    OpenStruct.new(success?: true, error: nil)
  end

  def failure(message)
    OpenStruct.new(success?: false, error: message)
  end
end
