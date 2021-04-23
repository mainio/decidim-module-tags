# frozen_string_literal: true

module Decidim
  module Tags
    # A form object to be used when admin users want to add taggings to a
    # record.
    class TaggingsForm < Decidim::Form
      mimic :taggings

      alias organization current_organization

      attribute :tags, Array[Integer]

      validates :organization, presence: true

      def map_model(model)
        self.tags = model.tags.map(&:id)
      end

      def tag_models
        Decidim::Tags::Tag.where(id: tags)
      end
    end
  end
end
