# frozen_string_literal: true

module Decidim
  module Tags
    # This query class filters all assemblies given an organization.
    class OrganizationTags < Decidim::Query
      def initialize(organization, locale = nil)
        @organization = organization
        @locale = locale || I18n.locale.to_s
      end

      def query
        q = Decidim::Tags::Tag.where(
          organization: @organization
        )
        q.order(Arel.sql("name ->> #{q.connection.quote(@locale)} ASC"))
      end
    end
  end
end
