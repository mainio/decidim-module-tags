# frozen_string_literal: true

module Decidim
  module Tags
    # This module provides the tags API endpoints.
    module QueryExtensions
      # Public: Extends a type with custom fields.
      #
      # type - A GraphQL::BaseType to extend.
      #
      # Returns nothing.
      def self.included(type)
        type.field :tags, [Decidim::Tags::TagType], null: true, description: "The tags for current organization" do
          argument :name, GraphQL::Types::String, "The name of the tag", required: false
          argument :locale, GraphQL::Types::String, "The locale of the tag", required: false
        end

        def tags(name: "", locale: nil)
          Decidim::Tags::TagsResolver.new(
            context[:current_organization],
            name,
            locale
          ).tags
        end
      end
    end
  end
end
