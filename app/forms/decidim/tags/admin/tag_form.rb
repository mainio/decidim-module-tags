# frozen_string_literal: true

module Decidim
  module Tags
    module Admin
      # A form object to be used when users want to add new tags to the system.
      class TagForm < Decidim::Form
        include Decidim::TranslatableAttributes

        mimic :tag

        alias organization current_organization

        translatable_attribute :name, String

        # The taggable_id can be used when the user needs to be redirected back
        # to the resource taggings after the update.
        attribute :taggable_id, String

        validates :name, translatable_presence: true
      end
    end
  end
end
