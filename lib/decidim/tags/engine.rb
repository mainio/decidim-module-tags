# frozen_string_literal: true

module Decidim
  module Tags
    # This is an engine that controls the tags functionality.
    class Engine < ::Rails::Engine
      isolate_namespace Decidim::Tags

      initializer "decidim_tags.query_extensions" do
        Decidim::Api::QueryType.include Decidim::Tags::QueryExtensions
      end

      initializer "decidim_tags.add_cells_view_paths" do
        Cell::ViewModel.view_paths << File.expand_path("#{Decidim::Tags::Engine.root}/app/cells")
      end
    end
  end
end
