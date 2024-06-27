# frozen_string_literal: true

require "decidim/dev"

ENV["ENGINE_ROOT"] = File.dirname(__dir__)

Decidim::Dev.dummy_app_path =
  File.expand_path(File.join(__dir__, "decidim_dummy_app"))

require "decidim/tags/test/railtie"
require "decidim/dev/test/base_spec_helper"

# This re-registration is made because of problems with chromedriver v120.
# Selenium methods are undefined without this change.
# See: https://github.com/decidim/decidim/pull/12160
require "#{ENV.fetch("ENGINE_ROOT")}/lib/decidim/privacy/test/rspec_support/capybara"

# Make the DummyResource taggable for the specs.
Decidim::DummyResources::DummyResource.include(Decidim::Tags::Taggable)
Decidim::DummyResources::NestedDummyResource.include(Decidim::Tags::Taggable)
Decidim::DummyResources::DummyResourceForm.include(Decidim::Tags::TaggableForm)

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

RSpec.configure do |config|
  config.before do
    # Re-define the password validators due to a bug in the "email included"
    # check which does not work well for domains such as "1.lvh.me" that we are
    # using during tests.
    PasswordValidator.send(:remove_const, :VALIDATION_METHODS)
    PasswordValidator.const_set(
      :VALIDATION_METHODS,
      [
        :password_too_short?,
        :password_too_long?,
        :not_enough_unique_characters?,
        :name_included_in_password?,
        :nickname_included_in_password?,
        # :email_included_in_password?,
        :domain_included_in_password?,
        :password_too_common?,
        :blacklisted?
      ].freeze
    )
  end
end
