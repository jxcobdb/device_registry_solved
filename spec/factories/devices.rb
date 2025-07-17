FactoryBot.define do
  factory :device do
    sequence(:serial_number) { |n| "SN#{n}" }
    user { nil }
  end
end