# frozen_string_literal: true

module Terminus
  module Actions
    module Playlists
      # The show action.
      class Show < Terminus::Action
        include Deps[
          :htmx,
          repository: "repositories.playlist",
          item_repository: "repositories.playlist_item"
        ]

        params { required(:id).filled :integer }

        def handle request, response
          parameters = request.params

          halt :unprocessable_entity unless parameters.valid?

          response.render view, **view_settings(request, parameters)
        end

        private

        def view_settings request, parameters
          playlist = repository.find parameters[:id]
          settings = {playlist:, items: item_repository.all_by(playlist_id: playlist.id)}
          settings[:layout] = false if htmx.request(**request.env).request?
          settings
        end
      end
    end
  end
end
