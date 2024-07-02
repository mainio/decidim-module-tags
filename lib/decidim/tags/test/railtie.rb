# frozen_string_literal: true

require "rails"

module Decidim
  # The DummyResources::Admin module needs to be defined in order for the
  # isolate_namespace definition to work.
  module DummyResources
    module Admin
    end
  end

  module Tags
    module Test
      # This railtie allows us to inject some extra stuff to the test
      # application before the routes are loaded.
      class Railtie < Rails::Railtie
        # Overrides the dummy resources admin engine routes.
        initializer "decidim_tags_test.mount_routes", before: "decidim_admin.mount_routes" do
          Decidim::Dev::AdminEngine.class_eval do
            isolate_namespace Decidim::DummyResources::Admin

            routes.prepend do
              resources :dummy_resources do
                resource :taggings, only: [:show, :update]
              end

              # This is just to test the breadcrumbs naming when the title
              # is not translatable. The view expects to find these paths in
              # the engine.
              resources :nested_dummy_resources do
                resource :taggings, only: [:show, :update]
              end
            end
          end
        end

        # Require the dummy resources controller in the to_prepare hook because
        # otherwise the mounted helper methods for navigating between the
        # engines would not be available in the controller or its views.
        initializer "decidim_tags_test.prepare" do
          config.to_prepare do
            require "decidim/tags/test/dummy_resources_admin"
          end
        end
      end
    end
  end
end
