# frozen_string_literal: true

module Terminus
  module Repositories
    # The screen repository.
    class Screen < DB::Repository[:screen]
      commands :create, update: :by_pk

      def all
        with_associations.order { updated_at.desc }
                         .to_a
      end

      def all_by(**)
        with_associations.where(**)
                         .order { created_at.asc }
                         .to_a
      end

      def delete id
        find(id).then { it.image_destroy if it }
        screen.by_pk(id).delete
      end

      def find(id) = (with_associations.by_pk(id).one if id)

      def find_by(**) = with_associations.where(**).one

      private

      def with_associations = screen.combine :model
    end
  end
end
