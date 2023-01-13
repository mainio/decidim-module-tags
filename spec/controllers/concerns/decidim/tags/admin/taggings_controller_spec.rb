# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Tags
    module Admin
      describe "TaggingsController", type: :controller do
        controller Decidim::DummyResources::Admin::TaggingsController do
          # Empty block
        end

        let(:taggable) { create(:dummy_resource) }
        let(:component) { taggable.component }
        let(:organization) { component.organization }
        let(:user) { create(:user, :admin, organization: organization) }
        let!(:tags) { create_list(:tag, 5, organization: organization) }

        before do
          request.env["decidim.current_organization"] = organization
          request.env["decidim.current_component"] = component
          sign_in user, scope: :user
          taggable.update!(tags: tags)

          routes.draw do
            get "show" => "decidim/dummy_resources/admin/taggings#show"
            get "update" => "decidim/dummy_resources/admin/taggings#update"
          end
        end

        describe "GET show" do
          render_views

          it "renders the show view successfully" do
            get :show, params: { dummy_resource_id: taggable.id }
            expect(response).to have_http_status(:ok)
            expect(subject).to render_template("decidim/tags/admin/taggings/show")
            expect(assigns(:form).tags).to match_array(tags.map(&:id))
          end
        end

        describe "PATCH update" do
          render_views

          let(:params) { { tags: new_tags.map(&:id), dummy_resource_id: taggable.id } }
          let(:new_tags) { create_list(:tag, 5, organization: organization) }
          let(:final) { Decidim::DummyResources::DummyResource.find(taggable.id) }

          it "updates the record successfully" do
            patch :update, params: params

            expect(response).to redirect_to("/dummy_resources")
            expect(final.tags.map(&:id)).to match_array(new_tags.map(&:id))
          end

          context "when no organization is available" do
            let(:builder) { double }
            let(:form) { Decidim::Tags::TaggingsForm.from_params(params) }

            before do
              # Return the form without the context when the organization is not
              # available.
              allow(controller).to receive(:form).with(Decidim::Tags::TaggingsForm).and_return(builder)
              allow(builder).to receive(:from_params).and_return(form)
            end

            it "displays an error and renders the show view" do
              patch :update, params: params

              expect(response).to have_http_status(:ok)
              expect(flash[:alert]).to be_present
              expect(subject).to render_template("decidim/tags/admin/taggings/show")
            end
          end
        end
      end
    end
  end
end
