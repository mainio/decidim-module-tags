# frozen_string_literal: true

module Decidim
  module Tags
    # A tag is a record that allows providing metadata for the items to be
    # tagged, i.e. the "taggables".
    class Tag < ::Decidim::Tags::ApplicationRecord
      belongs_to :organization,
                 foreign_key: :decidim_organization_id,
                 class_name: "Decidim::Organization"
      has_many :taggings, foreign_key: :decidim_tags_tag_id, dependent: :destroy
    end
  end
end
