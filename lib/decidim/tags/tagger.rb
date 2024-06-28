# frozen_string_literal: true

module Decidim
  module Tags
    # A utility class that creates a tagging for a resource.
    class Tagger
      def initialize(taggable:, organization:)
        @taggable = taggable
        @organization = organization
      end

      def apply(ids)
        tags = Tag.where(id: ids, organization:)

        taggable.taggings.destroy_all
        return unless tags.any?

        taggable.taggings.create!(tags.map { |tag| { tag: } })
      end

      private

      attr_reader :taggable, :organization
    end
  end
end
