class Building < ApplicationRecord
  attr_accessor :custom_fields

  belongs_to :client
  has_many :custom_field_values, dependent: :destroy

  validates :address, presence: true
  validates :city, presence: true
  validates :state_abbr, presence: true
  validates :postal_code, presence: true
  validate :validate_custom_fields

  private

  def validate_custom_fields
    return unless client && custom_fields

    validate_unknown_fields

    client.custom_fields.each do |cf|
      value = custom_fields[cf.name]

      case cf.field_type
      when "number"
        validate_number_field(cf, value)
      when "enumeration"
        validate_enum_field(cf, value)
      end
    end
  end


  def validate_unknown_fields
    return unless client && custom_fields

    submitted_fields = custom_fields.keys
    valid_fields = client.custom_fields.pluck(:name)

    unknown_fields = submitted_fields - valid_fields
    unknown_fields.each do |field|
      errors.add(:base, "Invalid field: #{field}")
    end
  end

  def validate_number_field(field, value)
    return if value.blank?

    begin
      Float(value)
    rescue ArgumentError, TypeError
      errors.add(field.name, "must be a valid number")
    end
  end

  def validate_enum_field(field, value)
    return if value.blank?
    return if field.options.include?(value)

    errors.add(field.name, "must be one of: #{field.options.join(', ')}")
  end
end
