module Api
  class BuildingsController < ApplicationController
    skip_before_action :verify_authenticity_token
    before_action :set_building, only: [ :update ]

    def index
      buildings = Building.includes(
        :client,
        :custom_field_values,
        client: :custom_fields
      ).page(params[:page]).per(5)

      if client_id = params[:client_id].present?
        buildings = buildings.where(client_id:)
      end

      render json: format_responses(buildings)
    end

    def create
      @building = Building.new(building_params.except(:custom_fields))
      @building.custom_fields = building_params[:custom_fields] || {}

      if @building.save
        create_custom_field_values
        render json: format_response(@building), status: :created
      else
        render_error
      end
    end

    def update
      @building.assign_attributes(building_params.except(:custom_fields))
      @building.custom_fields = building_params[:custom_fields] || {}

      if @building.save
        update_custom_field_values
        render json: format_response(@building)
      else
        render_error
      end
    end


    private

    def building_params
      params.require(:building).permit(
        :address, :city, :state_abbr, :postal_code, :client_id,
        custom_fields: {}
      )
    end

    def set_building
      @building = Building.find_by(id: params[:id]) or raise ActionController::RoutingError.new("Not Found")
    end

    def create_custom_field_values
      @building.client.custom_fields.each do |cf|
        value = @building.custom_fields[cf.name]
        @building.custom_field_values.create!(
          custom_field: cf,
          value: value.to_s
        )
      end
    end

    def update_custom_field_values
      @building.custom_field_values.destroy_all
      create_custom_field_values
    end

    def render_error
      render json: {
        status: "error",
        errors: @building.errors.full_messages
      }, status: :unprocessable_entity
    end

    def format_responses(buildings)
      {
        status: "success",
        buildings: buildings.map do |building|
          building_hash(building)
        end
      }
    end

    def format_response(building)
      {
        status: "success",
        building: building_hash(building)
      }
    end

    def building_hash(building)
      response = {
        id: building.id.to_s,
        client_name: building.client.name,
        address: building.address,
        city: building.city,
        state_abbr: building.state_abbr,
        postal_code: building.postal_code
      }

      existing_values = building.custom_field_values
        .includes(:custom_field)
        .each_with_object({}) { |cfv, h| h[cfv.custom_field.name] = cfv.value.to_s }

      building.client.custom_fields.each do |cf|
        response[cf.name] = existing_values[cf.name] || ""
      end

      response
    end
  end
end
