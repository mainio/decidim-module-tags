# frozen_string_literal: true

module Decidim
  module Tags
    # This cell renders the tags for the given record.
    class TagsCell < Decidim::ViewModel
      include Decidim::TranslatableAttributes

      # After Rails 6 upgrade we can use `private: true` in the delegate call.
      delegate :tags, to: :model
      private :tags

      def show
        return unless tags.any?

        render
      end
    end
  end
end
