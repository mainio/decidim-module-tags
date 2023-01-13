# frozen_string_literal: true

module Decidim
  module Tags
    module Admin
      # This module provides the resource tagging interface in the admin panel.
      # This can be attached to the admin views of records if the tags need to
      # be controlled separately from the records by admins. If you control the
      # tags inside the record form, you won't need this.
      #
      # You should always prefer to update the tags during the record updates
      # as described in the documentation.
      #
      # If you need this, do the following:
      #
      # 1. Add the admin engine routes for your resource
      #   routes do
      #     resources :your_records do
      #       # NOTE: The singular format of `resource` is necessary.
      #       resource :taggings, only: [:show, :update]
      #     end
      #   end
      #
      # 2. Create the controller
      #   module Decidim
      #     module Foo
      #       module Admin
      #         class YourRecordsController < Admin::ApplicationController
      #           include Decidim::Tags::Admin::TaggingsController
      #
      #           before_action do
      #             enforce_permission_to :update, :your_record, your_record: taggable
      #           end
      #
      #           private
      #
      #           def taggable
      #             @taggable ||= YourRecord.find(params[:your_record_id])
      #           end
      #         end
      #       end
      #     end
      #   end
      #
      # 3. Add the link next to the record for editing the tags:
      #   <%= link_to "Manage tags", your_record_taggings_path(your_record) %>
      module TaggingsController
        extend ActiveSupport::Concern

        included do
          include Decidim::TranslatableAttributes

          helper_method :taggable, :taggable_name, :taggable_return_path, :taggable_update_taggings_path
        end

        def show
          @form = form(Decidim::Tags::TaggingsForm).from_model(taggable)

          render "decidim/tags/admin/taggings/show"
        end

        def update
          @form = form(Decidim::Tags::TaggingsForm).from_params(params)
          # raise @form.tags.inspect
          Decidim::Tags::UpdateTaggings.call(@form, taggable) do
            on(:ok) do
              flash[:notice] = I18n.t("taggings.update.success", scope: "decidim.tags.admin")
              redirect_to taggable_return_path
            end

            on(:invalid) do
              flash.now[:alert] = I18n.t("taggings.update.invalid", scope: "decidim.tags.admin")
              render "decidim/tags/admin/taggings/show"
            end
          end
        end

        private

        def taggable
          raise NotImplementedError, "You need to define the taggable resource"
        end

        def taggable_name
          name = taggable.try(:title) || taggable.try(:name) || taggable.try(:subject) || taggable.model_name.human
          return translated_attribute(name) if name.is_a?(Hash)

          name
        end

        def taggable_return_path
          send("#{taggable.model_name.route_key}_path")
        end

        def taggable_update_taggings_path
          send("#{taggable.model_name.singular_route_key}_taggings_path", taggable)
        end
      end
    end
  end
end
