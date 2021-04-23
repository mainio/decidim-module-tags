# frozen_string_literal: true

lib = File.expand_path("lib", __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "decidim/tags/version"

Gem::Specification.new do |spec|
  spec.name = "decidim-tags"
  spec.version = Decidim::Tags::VERSION
  spec.required_ruby_version = ">= 2.6"
  spec.authors = ["Antti Hukkanen"]
  spec.email = ["antti.hukkanen@mainiotech.fi"]

  spec.summary = "Adds possibility to add tags to any records."
  spec.description = "Developers can define the tags functionality to any existing objects and the users can add tags to different records."
  spec.homepage = "https://github.com/mainio/decidim-module-tags"
  spec.license = "AGPL-3.0"

  spec.files = Dir[
    "{app,config,lib}/**/*",
    "LICENSE-AGPLv3.txt",
    "Rakefile",
    "README.md"
  ]

  spec.require_paths = ["lib"]

  spec.add_dependency "decidim-core", Decidim::Tags::DECIDIM_VERSION

  spec.add_development_dependency "decidim-dev", Decidim::Tags::DECIDIM_VERSION
end
