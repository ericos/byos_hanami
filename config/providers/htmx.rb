# frozen_string_literal: true

Hanami.app.register_provider :htmx do
  prepare { require "htmx" }

  start { register :htmx, HTMX }
end
