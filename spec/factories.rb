FactoryBot.define do
  factory :client do
    sequence(:name) { |n| "Client #{n}" }
  end

  factory :custom_field do
    sequence(:name) { |n| "field_#{n}" }
    field_type { 'number' }
    client
  end

  factory :building do
    address { "456 Oak St" }
    city { "Chicago" }
    state_abbr { "IL" }
    postal_code { "60007" }
    client
  end
end
