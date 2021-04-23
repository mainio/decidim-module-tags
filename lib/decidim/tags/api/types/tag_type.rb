# frozen_string_literal: true

module Decidim
  module Tags
    class TagType < GraphQL::Schema::Object
      graphql_name "Tag"
      description "A tag"

      field :id, GraphQL::Types::ID, null: false
      field :name, Decidim::Core::TranslatedFieldType, "The name for this tag", null: true
    end
  end
end
