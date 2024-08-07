# frozen_string_literal: true

module Decidim
  module Tags
    module Admin
      # This is the engine that runs on the admin interface of `decidim-tags`.
      class Engine < ::Rails::Engine
        isolate_namespace Decidim::Tags::Admin

        paths["db/migrate"] = nil
        paths["lib/tasks"] = nil

        routes do
          resources :tags, except: [:show]

          root to: "tags#index"
        end

        initializer "decidim_tags_admin.mount_routes", before: "decidim_admin.mount_routes" do
          # Mount the engine routes to Decidim::Core::Engine because otherwise
          # they would not get mounted properly.
          Decidim::Admin::Engine.routes.append do
            mount Decidim::Tags::Admin::Engine => "/"
          end
        end

        initializer "decidim_tags_admin.admin_menu" do
          Decidim.menu :admin_menu do |menu|
            menu.add_item :tags,
                          I18n.t("menu.tags", scope: "decidim.tags.admin"),
                          decidim_tags_admin.tags_path,
                          icon_name: "price-tag-line",
                          position: 7.1,
                          active: :inclusive,
                          if: allowed_to?(:update, :organization, organization: current_organization)
          end
        end

        initializer "decidim_core.register_icons", after: "decidim_core.add_social_share_services" do
          Decidim.icons.register(name: "price-tag-line", icon: "price-tag-line", category: "system", description: "", engine: :core)
        end
      end
    end
  end
end
