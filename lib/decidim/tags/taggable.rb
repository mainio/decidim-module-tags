# frozen_string_literal: true

module Decidim
  module Tags
    # A concern that needs to be included in all records that need tags.
    module Taggable
      extend ActiveSupport::Concern

      included do
        has_many :taggings,
                 as: :taggable,
                 foreign_key: :decidim_taggable_id,
                 foreign_type: :decidim_taggable_type,
                 class_name: "Decidim::Tags::Tagging",
                 dependent: :destroy
        has_many :tags, through: :taggings
      end
    end
  end
end
