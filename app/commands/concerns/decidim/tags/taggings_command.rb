# frozen_string_literal: true

module Decidim
  module Tags
    # This concern can be added in any other command that updates record tags.
    # For example, if you want to update the record tags in UpdateRecord
    # command, you should do the following:
    #
    # 1. Include the Decidim::Tags::TaggableForm concern to the record form
    #    class
    # 2. Add the tags input to the record form view (see README)
    # 3. Include this concern to the UpdateRecord command
    # 4. After the record is updated, call `update_taggings(taggable, form)`
    module TaggingsCommand
      extend ActiveSupport::Concern

      private

      def update_taggings(taggable, form)
        organization =
          if taggable.respond_to?(:organization)
            taggable.organization
          elsif form.respond_to?(:organization)
            form.organization
          else
            form.current_component.organization
          end

        tagger = Tagger.new(
          taggable:,
          organization:
        )
        tagger.apply(form.taggings&.tags)
      end
    end
  end
end
