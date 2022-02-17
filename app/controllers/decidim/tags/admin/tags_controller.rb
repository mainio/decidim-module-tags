# frozen_string_literal: true

module Decidim
  module Tags
    module Admin
      # This controller allows admins to control the tag records.
      class TagsController < ::Decidim::Tags::Admin::ApplicationController
        include TranslatableAttributes

        # For some reason the specs sometimes break without including this.
        helper Decidim::LayoutHelper

        helper_method :tags

        def index
          enforce_permission_to :read, :tags
        end

        def new
          enforce_permission_to :create, :tag

          dummy_tag = Tag.new(organization: current_organization)
          dummy_tag.name = {}
          current_organization.available_locales.map do |locale|
            dummy_tag.name[locale] = params[:name]
          end

          @form = form(Admin::TagForm).from_model(dummy_tag)
          @form.taggable_id = taggable.to_sgid.to_s if taggable
        end

        def create
          enforce_permission_to :create, :tag
          @form = form(Admin::TagForm).from_params(params)

          Admin::CreateTag.call(@form) do
            on(:ok) do
              flash[:notice] = I18n.t("create.success", scope: i18n_flashes_scope)

              redirect_to return_path
            end

            on(:invalid) do
              flash.now[:alert] = I18n.t("create.invalid", scope: i18n_flashes_scope)
              render action: "new"
            end
          end
        end

        def edit
          enforce_permission_to :edit, :tag, tag: tag
          @form = form(Admin::TagForm).from_model(tag)
        end

        def update
          enforce_permission_to :edit, :tag, tag: tag

          @form = form(Admin::TagForm).from_params(params)
          Admin::UpdateTag.call(@form, @tag) do
            on(:ok) do
              flash[:notice] = I18n.t("update.success", scope: i18n_flashes_scope)
              redirect_to return_path
            end

            on(:invalid) do
              flash.now[:alert] = I18n.t("update.invalid", scope: i18n_flashes_scope)
              render :edit
            end
          end
        end

        def destroy
          enforce_permission_to :destroy, :tag, tag: tag

          Admin::DestroyTag.call(@tag, current_user) do
            on(:ok) do
              flash[:notice] = I18n.t("destroy.success", scope: i18n_flashes_scope)
              redirect_to tags_path
            end

            on(:invalid) do
              flash.now[:alert] = I18n.t("destroy.error", scope: i18n_flashes_scope)
              redirect_to tags_path
            end
          end
        end

        private

        def i18n_flashes_scope
          "decidim.tags.admin.tags"
        end

        def tag
          @tag ||= Tag.where(organization: current_organization).find(params[:id])
        end

        def tags
          @tags ||= OrganizationTags.new(
            current_organization
          ).query.page(params[:page]).per(30)
        end

        def taggable
          return unless params[:taggable_id]

          @taggable ||= GlobalID::Locator.locate_signed(params[:taggable_id])
        end

        def return_path
          if taggable
            proxy = ::Decidim::ResourceLocatorPresenter.new(taggable).send(:admin_route_proxy)
            return proxy.public_send(
              "#{taggable.model_name.singular_route_key}_taggings_path",
              taggable
            )
          end

          tags_path
        end
      end
    end
  end
end
