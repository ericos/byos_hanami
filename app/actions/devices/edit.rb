# frozen_string_literal: true

require "initable"

module Terminus
  module Actions
    module Devices
      # The edit action.
      class Edit < Terminus::Action
        include Deps[:htmx, repository: "repositories.device"]
        include Initable[model_optioner: proc { Terminus::Aspects::Models::Optioner }]

        params { required(:id).filled :integer }

        def handle request, response
          parameters = request.params

          halt :unprocessable_entity unless parameters.valid?

          response.render view, **view_settings(request, parameters)
        end

        private

        def view_settings request, parameters
          settings = {model_options: model_optioner.call, device: repository.find(parameters[:id])}
          settings[:layout] = false if htmx.request(**request.env).request?
          settings
        end
      end
    end
  end
end
