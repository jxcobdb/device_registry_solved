# frozen_string_literal: true

class ReturnDeviceFromUser
  def initialize(user:, device:)
    @user = user
    @device = device
  end

  def call
    return failure("User does not exist") unless user.present?
    return failure("Device does not exist") unless device.present?
    return failure("Device does not belong to the user") unless device.user == user

    ActiveRecord::Base.transaction do
      device.update!(user: nil)
      AssignmentHistory.create!(user: user, device: device, action: "returned")
    end

    success
  end

  private

  attr_reader :user, :device

  def success
    OpenStruct.new(success?: true, error: nil)
  end

  def failure(message)
    OpenStruct.new(success?: false, error: message)
  end
end

