# frozen_string_literal: true

module Decidim
  module Tags
    # A GraphQL resolver to handle `tags'
    class TagsResolver
      def initialize(organization, term, locale = nil)
        @organization = organization
        @term = term
        @locale = locale || organization.default_locale
      end

      def tags
        tags = OrganizationTags.new(@organization, @locale).query

        if @term && @term.present?
          tags = tags.where(
            "name ->> ? ILIKE ?",
            @locale,
            "%#{@term}%"
          )
        end

        tags
      end
    end
  end
end
