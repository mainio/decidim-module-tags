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
        # The model can be a collection proxy if the map_model is called through
        # the parent record's map_model method.
        if model.is_a?(ActiveRecord::Associations::CollectionProxy)
          if model.first && model.first.respond_to?(:decidim_tags_tag_id)
            self.tags = model.map(&:decidim_tags_tag_id)
          else
            self.tags = model.map(&:id)
          end
        else
          self.tags = model.tags.map(&:id)
        end
      end

      def tag_models
        Decidim::Tags::Tag.where(id: tags)
      end
    end
  end
end
