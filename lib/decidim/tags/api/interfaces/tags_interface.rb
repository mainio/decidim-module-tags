# frozen_string_literal: true

module Decidim
  module Tags
    module TagsInterface
      include GraphQL::Schema::Interface

      graphql_name "TagsInterface"
      description "This interface is implemented by any object that can have tags."

      field :tags, [Decidim::Tags::TagType], null: true do
        description "The tags for this record"
      end
    end
  end
end
