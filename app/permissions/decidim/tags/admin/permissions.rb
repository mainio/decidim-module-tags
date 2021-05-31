# frozen_string_literal: true

module Decidim
  module Tags
    module Admin
      class Permissions < Decidim::DefaultPermissions
        def permissions
          return permission_action unless user
          return permission_action if permission_action.scope != :admin
          return permission_action if permission_action.subject != :tag &&
                                      permission_action.subject != :tags

          case permission_action.subject
          when :tags
            case permission_action.action
            when :read
              can_read_tags?
            end
          when :tag
            case permission_action.action
            when :create
              can_create_tags?
            when :edit
              can_edit_tag?
            when :destroy
              can_destroy_tag?
            end
          end

          permission_action
        end

        private

        def can_read_tags?
          toggle_allow(user.admin?)
        end

        def can_create_tags?
          toggle_allow(user.admin?)
        end

        def can_edit_tag?
          toggle_allow(user.admin? && tag.present?)
        end

        def can_destroy_tag?
          toggle_allow(user.admin? && tag.present?)
        end

        def tag
          @tag ||= context.fetch(:tag, nil)
        end
      end
    end
  end
end
