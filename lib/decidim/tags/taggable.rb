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

        # This scope can be used as a ransack filter. To make it possible to
        # filter using this scope, you also need to add the following to your
        # model (note that you may also want to add some other scopes):
        #
        #   def self.ransackable_scopes(_auth_object = nil)
        #     [:with_any_tag]
        #   end
        #
        # After this, you are able to filter within your controllers using this
        # scope by adding the following to the controller performing the search
        # (note that you may also want to include some other filters):
        #
        #  def default_filter_params
        #    { with_any_tag: [] }
        #  end
        scope :with_any_tag, lambda { |*tags|
          provided_tags = tags.compact_blank
          return self if provided_tags.empty?

          # Fetch the record IDs as a separate query in order to avoid duplicate
          # entries in the final result. We could also use `.distinct` on the
          # main query but that would limit what the user could further on do
          # with that query. Therefore, in this context it is safer to just
          # fetch these in a completely separate query.
          record_ids = joins(:tags).where(decidim_tags_tags: { id: provided_tags }).distinct.pluck(:id)

          where(id: record_ids)
        }
      end
    end
  end
end
