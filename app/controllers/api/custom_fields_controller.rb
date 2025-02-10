module Api
  class CustomFieldsController < ApplicationController
    def index
      custom_fields = CustomField.where(client_id: params[:client_id])
      render json: format_response(custom_fields)
    end


    private

    def format_response(custom_fields)
      {
        status: "success",
        custom_fields: custom_fields.map { |custom_field| custom_field }
      }
    end
  end
end
