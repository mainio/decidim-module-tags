# frozen_string_literal: true

module Decidim
  module Tags
    # This is an engine that controls the tags functionality.
    class Engine < ::Rails::Engine
      isolate_namespace Decidim::Tags

      initializer "decidim_tags.query_extensions" do
        Decidim::Api::QueryType.define do
          Decidim::Tags::QueryExtensions.define(self)
        end

        # TODO: After update to 0.24:
        # Decidim::Api::QueryType.include Decidim::Assemblies::QueryExtensions
      end

      initializer "decidim_tags.add_cells_view_paths" do
        Cell::ViewModel.view_paths << File.expand_path("#{Decidim::Tags::Engine.root}/app/cells")
      end

      initializer "decidim_tags.assets" do |app|
        app.config.assets.precompile += %w(decidim_tags_manifest.js)
      end
    end
  end
end
