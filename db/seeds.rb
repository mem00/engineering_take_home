# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end
5.times do |i|
  client = Client.find_or_create_by!(
    name: Faker::Company.unique.name
  )

  custom_fields = [
    {
      name: Faker::Commerce.unique.department + " (number)",
      field_type: :number
    },
    {
      name: Faker::Commerce.unique.department + " (freeform)",
      field_type: :freeform
    },
    {
      name: Faker::Commerce.unique.department + " (enum)",
      field_type: :enumeration,
      options: Array.new(3) { Faker::Commerce.material }.uniq
    }
  ]

  custom_fields.each do |custom_field|
    client.custom_fields.find_or_create_by!(custom_field)
  end

  2.times do
    building = client.buildings.find_or_create_by!(
      address: Faker::Address.street_address,
      city: Faker::Address.city,
      state_abbr: Faker::Address.state_abbr,
      postal_code: Faker::Address.zip
    )

    client.custom_fields.each do |custom_field|
      value = case custom_field.field_type
      when 'number'
                Faker::Number.between(from: 1, to: 1000).to_s
      when 'freeform'
                Faker::Lorem.sentence
      when 'enumeration'
                custom_field.options.sample
      end

      building.custom_field_values.find_or_create_by!(
        custom_field:,
        value:
      )
    end
  end
end
