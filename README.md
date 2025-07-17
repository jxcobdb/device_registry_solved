# Device Registry Task

A simple Rails API application for tracking devices assigned to users.

## Features
- Users can assign unassigned devices to themselves
- Users can return devices (and cannot reassign the same device again)
- Assignment history is tracked for all device-user actions

## Requirements
- Ruby 3.2.3
- Rails >= 7.1.3.4
- SQLite3

## Setup

1. Clone the repository
2. Install dependencies:

        bundle install

3. Set up the database:

        rails db:setup

    for test DB

        rails db:test:prepare

4. Run the test suite:

        bundle exec rspec

## Product Rules
- Users can only assign devices to themselves
- Users cannot assign a device already assigned to another user
- Only the user who assigned a device can return it
- If a user returns a device, they cannot reassign it to themselves again


## Development
- Main logic is in `app/services/assign_device_to_user.rb` and `app/services/return_device_from_user.rb`
- API endpoints are in `app/controllers/devices_controller.rb`
- Assignment history is tracked in the `assignment_histories` table

I did my best in those couple of days :D