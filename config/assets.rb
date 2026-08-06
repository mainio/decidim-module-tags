# frozen_string_literal: true

base_path = File.expand_path("..", __dir__)

Decidim::Shakapacker.register_path("#{base_path}/app/packs", prepend: true)

Decidim::Shakapacker.register_entrypoints(
  decidim_tags: "#{base_path}/app/packs/entrypoints/decidim_tags.js",
  decidim_tags_admin: "#{base_path}/app/packs/entrypoints/decidim_tags_admin.js"
)

Decidim::Shakapacker.register_stylesheet_import("stylesheets/decidim/tags/tagging-input")
Decidim::Shakapacker.register_stylesheet_import("stylesheets/decidim/tags/tagging-input", group: :admin)
