# frozen_string_literal: true

module Terminus
  module Actions
    module Devices
      module Logs
        # The index action.
        # :reek:DataClump
        class Index < Terminus::Action
          include Deps[
            :htmx,
            device_repository: "repositories.device",
            repository: "repositories.device_log"
          ]

          params do
            required(:device_id).filled :integer
            optional(:query).maybe :string
          end

          def handle request, response
            parameters = request.params

            halt :unprocessable_entity unless parameters.valid?

            device = device_repository.find parameters[:device_id]

            if htmx.request? request.env, :trigger, "search"
              render_search_results parameters, device, response
            else
              render_all parameters, device, response
            end
          end

          private

          def render_search_results parameters, device, response
            query = parameters[:query].to_s
            add_htmx_headers response, device, query

            response.render view, device:, logs: load_logs(device.id, query), query:, layout: false
          end

          def render_all parameters, device, response
            query = parameters[:query].to_s
            response.render view, device:, logs: load_logs(device.id, query), query:
          end

          def load_logs device_id, query
            return repository.where device_id: device_id if query.empty?

            repository.all_by_message device_id, query
          end

          def add_htmx_headers response, device, query
            return if query.empty?

            htmx.response! response.headers,
                           push_url: routes.path(:device_logs, device_id: device.id, query:)
          end
        end
      end
    end
  end
end
