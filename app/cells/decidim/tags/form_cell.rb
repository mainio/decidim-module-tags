# frozen_string_literal: true

module Decidim
  module Tags
    # This cell renders the tags input for the given form.
    class FormCell < Decidim::ViewModel
      include Decidim::TranslatableAttributes

      delegate :snippets, to: :controller

      def show
        append_javascript_pack_tag("decidim_tags")

        render
      end

      private

      def selected_tags(form)
        form.object.tag_models.pluck(:id).to_json
      end

      def tag_options
        Decidim::Tags::Tag.where(organization: current_organization)
      end

      def field_name(form)
        return "tags[]" if form.blank? || form.object_name.blank?

        "#{form.object_name}[tags][]"
      end

      def input_id(form)
        @input_id ||= options[:id] || begin
          base = form.object_name.gsub(/\]\[|[^-a-zA-Z0-9:.]/, "_").delete_suffix("_")
          "#{base}_tags"
        end
      end

      def form
        model
      end

      def label
        return false if options[:label] == false

        options[:label] || I18n.t("activemodel.attributes.taggings.tags")
      end
    end
  end
end
