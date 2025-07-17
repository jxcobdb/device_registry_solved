# frozen_string_literal: true

class DevicesController < ApplicationController
  before_action :authenticate_user!, only: %i[assign unassign]

  def assign
    serial_number = params[:serial_number] || params.dig(:device, :serial_number)
    device = Device.find_by(serial_number: serial_number)
    new_owner_id = params[:new_owner_id]

    if new_owner_id.present? && new_owner_id.to_i != @current_user.id
      return render json: { error: "Unauthorized" }, status: :unprocessable_entity
    end

    result = AssignDeviceToUser.new(
      requesting_user: @current_user,
      user: @current_user,
      device: device
    ).call

    if result.success?
      head :ok
    else
      render json: { error: result.error }, status: :unprocessable_entity
    end
  end

  def unassign
    device = Device.find_by(serial_number: params[:serial_number])

    if device.nil?
      return render json: { error: "Device does not exist" }, status: :unprocessable_entity
    end

    unless device.user == @current_user
      return render json: { error: "Unauthorized" }, status: :unprocessable_entity
    end

    result = ReturnDeviceFromUser.new(user: @current_user, device: device).call

    if result.success?
      head :ok
    else
      render json: { error: result.error }, status: :unprocessable_entity
    end
  end

  private

  def device_params
    params.permit(:serial_number)
  end
end
