# frozen_string_literal: true

module Decidim
  module Tags
    # This query class filters all tags for the given component. You need to
    # extend this class to provide the
    class ComponentRecordTags < Rectify::Query
      class << self
        attr_reader :taggable_class

        private

        def taggable(klass)
          @taggable_class = klass
        end
      end

      def initialize(component)
        @component = component
      end

      def query
        Decidim::Tags::Tag.joins(
          %(
            LEFT JOIN decidim_tags_taggings ON decidim_tags_taggings.decidim_taggable_type = '#{taggable_class.name}'
            AND decidim_tags_taggings.decidim_tags_tag_id = decidim_tags_tags.id
          )
        ).joins(
          "LEFT JOIN #{taggable_class.table_name} ON #{taggable_class.table_name}.id = decidim_tags_taggings.decidim_taggable_id"
        ).where(
          decidim_tags_tags: {
            decidim_organization_id: @component.organization.id
          },
          taggable_class.table_name.to_sym => {
            decidim_component_id: @component.id
          }
        ).having(
          "COUNT(decidim_tags_taggings.id) > 0"
        ).group(
          "decidim_tags_tags.id"
        ).order(
          Arel.sql("decidim_tags_tags.name ->> #{Decidim::Tags::Tag.connection.quote(current_locale)} ASC")
        )
      end

      private

      def taggable_class
        raise NotImplementedError, "You need to define the taggable class" unless self.class.taggable_class

        self.class.taggable_class
      end

      def current_locale
        I18n.locale.to_s
      end
    end
  end
end
