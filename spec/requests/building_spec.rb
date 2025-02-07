require 'rails_helper'
RSpec.describe "Buildings API", type: :request do
  let!(:client) { create(:client) }
  let!(:custom_fields) do
    [
      create(:custom_field, client:, name: 'floors', field_type: 'number'),
      create(:custom_field, client:, name: 'material', field_type: 'enumeration', options: [ 'Brick', 'Concrete' ])
    ]
  end

  let(:valid_attributes) do
    {
      building: {
        address: "123 Main St",
        city: "New York",
        state_abbr: "NY",
        postal_code: "10001",
        client_id: client.id,
        floors: "5",
        material: "Brick"
      }
    }
  end

  describe "POST /api/buildings" do
    context "with valid parameters" do
      it "creates a new building" do
        expect {
          post "/api/buildings", params: valid_attributes
        }.to change(Building, :count).by(1)

        expect(response).to have_http_status(:created)
        expect(json["status"]).to eq("success")
        expect(json["building"]["address"]).to eq("123 Main St")
      end
    end

    context "with invalid parameters" do
      it "returns errors for invalid custom field type" do
        invalid_params = valid_attributes.deep_merge(building: { custom_fields: { floors: "five" } })
        post "/api/buildings", params: invalid_params

        expect(response).to have_http_status(:unprocessable_entity)
        expect(json["status"]).to eq("error")
        expect(json["errors"]).to include("Floors must be a valid number")
      end

      it "returns errors for unknown custom fields" do
        invalid_params = valid_attributes.deep_merge(building: { custom_fields: { unknown_field: "value" } })
        post "/api/buildings", params: invalid_params

        expect(response).to have_http_status(:unprocessable_entity)
        expect(json['errors']).to include('Invalid field: unknown_field')
      end

      it "returns errors for missing required fields" do
        invalid_params = valid_attributes.deep_merge(building: { address: nil })
        post "/api/buildings", params: invalid_params

        expect(response).to have_http_status(:unprocessable_entity)
        expect(json["errors"]).to include("Address can't be blank")
      end
    end
  end

  describe "PUT /api/buildings/:id" do
    let!(:building) { create(:building, client:) }

    context "with valid parameters" do
      it "updates the building" do
        put "/api/buildings/#{building.id}", params: valid_attributes
        expect(response).to have_http_status(:success)
        expect(json['building']['address']).to eq('123 Main St')
      end
    end

    context "with invalid parameters" do
      it "returns errors for invalid updates" do
        invalid_params = valid_attributes.deep_merge(building: { custom_fields: { material: "Wood" } })
        put "/api/buildings/#{building.id}", params: invalid_params

        expect(response).to have_http_status(:unprocessable_entity)
        expect(json['errors']).to include('Material must be one of: Brick, Concrete')
      end

      it "returns 404 for non-existent building" do
        put "/api/buildings/9999", params: valid_attributes
        expect(response).to have_http_status(:not_found)
      end
    end
  end

  describe "GET /api/buildings" do
    let!(:buildings) { create_list(:building, 7, client:) }

    it "returns paginated buildings with custom fields" do
      get "/api/buildings"

      expect(response).to have_http_status(:success)
      expect(json['buildings'].size).to eq(5)
      expect(json['buildings'].first).to include(
        'id', 'client_name', 'address', 'floors', 'material'
      )
    end

    it "returns second page of results" do
      get "/api/buildings", params: { page: 2 }
      expect(json['buildings'].size).to eq(2)
    end

    it "returns empty custom fields when no values exist" do
      Building.destroy_all
      building = create(:building, client:)
      get "/api/buildings"

      found = json['buildings'].find { |b| b['id'] == building.id.to_s }
      expect(found['floors']).to be_empty
      expect(found['material']).to be_empty
    end

    it "includes client name and address info" do
      get "/api/buildings"
      building = json['buildings'].first

      expect(building['client_name']).to eq(client.name)
      expect(building).to include('address', 'city', 'state_abbr', 'postal_code')
    end
  end

  def json
    JSON.parse(response.body)
  end
end
