# frozen_string_literal: true

require "initable"
require "versionaire"

module Terminus
  module Actions
    module API
      module Setup
        # The show action.
        class Show < Base
          include Deps[
            repository: "repositories.device",
            device_defaulter: "aspects.devices.defaulter",
            welcomer: "aspects.screens.welcomer"
          ]

          include Initable[model: Aspects::API::Responses::Setup]

          using Refines::Actions::Response

          params do
            required(:HTTP_ID).filled Types::MACAddress
            optional(:HTTP_FW_VERSION).maybe Types::String.constrained(format: Versionaire::PATTERN)
          end

          def handle request, response
            environment = request.env
            result = contract.call environment

            if result.success?
              create environment, response
            else
              unprocessable_entity result.errors.to_h, response
            end
          end

          private

          def create environment, response
            mac_address, firmware_version = environment.values_at "HTTP_ID", "HTTP_FW_VERSION"
            device = repository.find_by(mac_address:)
            device ||= create_device mac_address, firmware_version
            welcomer.call device
            response.body = model.for(device).to_json
          end

          def create_device mac_address, firmware_version
            repository.create device_defaulter.call.merge(mac_address:, firmware_version:)
          end

          def unprocessable_entity errors, response
            body = problem[
              type: "/problem_details#device_setup",
              status: :unprocessable_entity,
              detail: "Invalid request headers.",
              instance: "/api/setup",
              extensions: {errors:}
            ]

            response.with body: body.to_json, format: :problem_details, status: 422
          end
        end
      end
    end
  end
end
