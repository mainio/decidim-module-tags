# frozen_string_literal: true

require_relative "tags/version"
require_relative "tags/engine"
require_relative "tags/api"
require_relative "tags/admin"

module Decidim
  module Tags
    autoload :Taggable, "decidim/tags/taggable"
    autoload :Tagger, "decidim/tags/tagger"
    autoload :QueryExtensions, "decidim/tags/query_extensions"
  end
end
