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
        # TODO: Update to 0.24
        type.field :tags, [Decidim::Tags::TagType], null: true, description: "The tags for current organization" do
          argument :name, GraphQL::Types::String, "The name of the tag", required: false
        end

        # type.field :tags do
        #   type types[Decidim::Tags::TagType]
        #   description "The tags for current organization"
        #   argument :name, types.String, "The name of the tag"
        #   argument :locale, types.String, "The locale in which to search the name"

        #   resolve lambda { |_obj, args, ctx|
        #     Decidim::Tags::TagsResolver.new(
        #       ctx[:current_organization],
        #       args[:name],
        #       args[:locale]
        #     ).tags
        #   }
        # end
      end
    end
  end
end
