# frozen_string_literal: true

require "decidim/dev"

require "simplecov"
SimpleCov.start "rails"
if ENV["CODECOV"]
  require "codecov"
  SimpleCov.formatter = SimpleCov::Formatter::Codecov
end

ENV["ENGINE_ROOT"] = File.dirname(__dir__)

Decidim::Dev.dummy_app_path =
  File.expand_path(File.join(__dir__, "decidim_dummy_app"))

require "decidim/tags/test/railtie"
require "decidim/dev/test/base_spec_helper"

# Make the DummyResource taggable for the specs.
Decidim::DummyResources::DummyResource.include(Decidim::Tags::Taggable)
Decidim::DummyResources::NestedDummyResource.include(Decidim::Tags::Taggable)
Decidim::DummyResources::DummyResourceForm.include(Decidim::Tags::TaggableForm)

# TODO: Update to 0.24
# This defines a custom endpoint for loading dummy resources through the API.
class DummyResourceType < GraphQL::Schema::Object
  graphql_name "DummyResource"
  description "A dummy resource"

  implements Decidim::Tags::TagsInterface

  field :id, GraphQL::Types::ID, null: false
end

module DummyExtension
  def self.included(type)
    type.field :dummy,
               [DummyResourceType],
               null: false,
               description: "A dummy resource object" do
      argument :id, GraphQL::Types::ID, description: "The ID of the dummy resource to be found", required: false
    end
  end

  def dummy(id:)
    Decidim::DummyResources::DummyResource.where(id: id)
  end
end

Decidim::Api::QueryType.include DummyExtension
# do
#   field :dummy do
#     type DummyResourceType
#     description "A dummy resource object"
#     argument :id, !types.ID, "The ID of the dummy resource to be found"

#     resolve lambda { |_obj, args, _ctx|
#       Decidim::DummyResources::DummyResource.find(args[:id])
#     }
#   end
# end
