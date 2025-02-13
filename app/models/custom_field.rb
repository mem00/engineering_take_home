class CustomField < ApplicationRecord
  belongs_to :client
  has_many :custom_field_values, dependent: :destroy

  enum field_type: {
    number: "number",
    freeform: "freeform",
    enumeration: "enumeration"
  }

  validates :name, presence: true, uniqueness: { scope: :client_id }
end
