# frozen_string_literal: true

module Decidim
  module Tags
    # A form object to be used when admin users want to add taggings to a
    # record.
    class TaggingsForm < Decidim::Form
      mimic :taggings

      alias organization current_organization

      attribute :tags, [Integer]

      validates :organization, presence: true

      def map_model(model)
        # The model can be a collection proxy if the map_model is called through
        # the parent record's map_model method.
        self.tags = if model.is_a?(ActiveRecord::Associations::CollectionProxy)
                      model.map(&:id)
                    else
                      model.tags.map(&:id)
                    end
      end

      def tag_models
        Decidim::Tags::Tag.where(id: tags)
      end
    end
  end
end
