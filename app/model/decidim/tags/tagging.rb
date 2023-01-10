# frozen_string_literal: true

module Decidim
  module Tags
    # A tagging is a record that maps the records with the tags.
    class Tagging < ::Decidim::Tags::ApplicationRecord
      belongs_to :taggable, foreign_key: :decidim_taggable_id, foreign_type: :decidim_taggable_type, polymorphic: true
      belongs_to :tag, class_name: "Decidim::Tags::Tag", foreign_key: :decidim_tags_tag_id
    end
  end
end
