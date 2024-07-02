# frozen_string_literal: true

module Decidim
  module DummyResources
    module Admin
      class DummyResourcesController < Decidim::Components::BaseController
        # This is needed to test the update tags as the user is redirected to
        # this view.
        def index
          render plain: "Dummy index"
        end
      end

      class TaggingsController < Decidim::Admin::Components::BaseController
        include Decidim::Tags::Admin::TaggingsController

        helper Decidim::LayoutHelper
        helper Decidim::Admin::IconLinkHelper

        private

        def taggable
          @taggable ||= if params[:nested]
                          Dev::NestedDummyResource.find(params[:dummy_resource_id])
                        else
                          Dev::DummyResource.find(params[:dummy_resource_id])
                        end
        end
      end
    end
  end
end
