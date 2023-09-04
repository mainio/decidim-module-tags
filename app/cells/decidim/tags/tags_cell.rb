# frozen_string_literal: true

module Decidim
  module Tags
    # This cell renders the tags for the given record.
    class TagsCell < Decidim::ViewModel
      include Decidim::TranslatableAttributes

      def show
        return unless tags.any?

        render
      end

      private

      def tags
        return [] unless model.respond_to?(:tags)

        model.tags
      end
    end
  end
end
