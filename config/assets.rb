# frozen_string_literal: true

base_path = File.expand_path("..", __dir__)

Decidim::Webpacker.register_path("#{base_path}/app/packs", prepend: true)

Decidim::Webpacker.register_entrypoints(
  decidim_tags: "#{base_path}/app/packs/entrypoints/decidim_tags.js",
  decidim_tags_admin: "#{base_path}/app/packs/entrypoints/decidim_tags_admin.js"
)

Decidim::Webpacker.register_stylesheet_import("stylesheets/decidim/tags/tagging-input")
Decidim::Webpacker.register_stylesheet_import("stylesheets/decidim/tags/tagging-input", group: :admin)
