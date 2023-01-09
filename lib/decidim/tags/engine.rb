# frozen_string_literal: true

module Decidim
  module Tags
    # This is an engine that controls the tags functionality.
    class Engine < ::Rails::Engine
      isolate_namespace Decidim::Tags

      initializer "decidim_tags.query_extensions" do
        # Decidim::Api::QueryType.define do
        #   Decidim::Tags::QueryExtensions.define(self)
        # end

        Decidim::Api::QueryType.include Decidim::Tags::QueryExtensions

        # TODO: After update to 0.24:
        # Decidim::Api::QueryType.include Decidim::Assemblies::QueryExtensions
      end

      initializer "decidim_tags.add_cells_view_paths" do
        Cell::ViewModel.view_paths << File.expand_path("#{Decidim::Tags::Engine.root}/app/cells")
      end

      initializer "decidim_tags.configure_devise", before: "decidim_core.after_initializers_folder" do
        # By default in Decidim this is set as 0. We need to have unconfirmed
        # access so that participant can verify his/her email.
        Decidim.unconfirmed_access_for = 1000.days
      end
    end
  end
end
