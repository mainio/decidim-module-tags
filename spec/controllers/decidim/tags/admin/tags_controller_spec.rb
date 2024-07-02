# frozen_string_literal: true

require "spec_helper"

describe Decidim::Tags::Admin::TagsController do
  routes { Decidim::Tags::Admin::Engine.routes }

  let(:organization) { create(:organization) }
  let(:user) { create(:user, :confirmed, :admin, organization:) }

  before do
    request.env["decidim.current_organization"] = organization
    sign_in user
  end

  describe "GET index" do
    render_views

    before do
      create_list(:tag, 10, organization:)
    end

    it "renders the index listing" do
      get :index

      expect(response).to have_http_status(:ok)
      expect(subject).to render_template(:index)
      expect(assigns(:tags).length).to eq(10)
    end
  end

  describe "GET new" do
    it "renders the empty form" do
      get :new
      expect(response).to have_http_status(:ok)
      expect(subject).to render_template(:new)
    end
  end

  describe "POST create" do
    context "when name is empty" do
      let(:params) do
        { name: { en: "" } }
      end

      it "shows an error" do
        post(:create, params:)

        expect(flash[:alert]).not_to be_empty
      end
    end

    context "when name is not empty" do
      let(:params) do
        { name: { en: "Lorem ipsum dolor" } }
      end

      it "creates a tag" do
        create_params = params
        expect do
          post :create, params: create_params
        end.to change(Decidim::Tags::Tag, :count).by(1)

        expect(flash[:notice]).not_to be_empty
        expect(response).to have_http_status(:found)
        expect(subject).to redirect_to(tags_path)
      end

      context "and a taggable resource is given in the params" do
        let(:participatory_space) { create(:participatory_process, organization:) }
        let(:component) { create(:component, manifest_name: "dummy", participatory_space:) }
        let(:taggable) { create(:dummy_resource, component:) }
        let(:locator) { double }
        let(:route_proxy) { double }

        before do
          allow(Decidim::ResourceLocatorPresenter).to receive(:new).and_return(locator)
          allow(locator).to receive(:admin_route_proxy).and_return(route_proxy)
          allow(route_proxy).to receive("#{taggable.model_name.singular_route_key}_taggings_path").and_return(
            "/dummy_resources/#{taggable.id}/taggings"
          )
        end

        it "creates a tag and redirects back to the taggable resource" do
          create_params = params.merge(taggable_id: taggable.to_sgid.to_s)
          expect do
            post :create, params: create_params
          end.to change(Decidim::Tags::Tag, :count).by(1)

          expect(flash[:notice]).not_to be_empty
          expect(response).to have_http_status(:found)
          expect(subject).to redirect_to("/dummy_resources/#{taggable.id}/taggings")
        end
      end
    end
  end

  describe "GET edit" do
    let(:tag) { create(:tag, organization:) }

    it "renders the edit view" do
      get :edit, params: { id: tag.id }
      expect(response).to have_http_status(:ok)
      expect(subject).to render_template(:edit)
    end
  end

  describe "PUT update" do
    let(:tag) { create(:tag, organization:) }

    context "when name is empty" do
      let(:params) do
        { name: { en: "" } }
      end

      it "shows an error" do
        put :update, params: {
          id: tag.id,
          name: { en: "" }
        }

        expect(flash[:alert]).not_to be_empty
      end
    end

    context "when name is not empty" do
      it "updates the tag" do
        put :update, params: {
          id: tag.id,
          name: {
            en: "Lorem ipsum dolor sit amet, consectetur adipiscing elit"
          }
        }
        expect(response).to have_http_status(:found)
      end
    end
  end

  describe "DELETE destroy" do
    let(:tag) { create(:tag, organization:) }

    it "destroys the tag" do
      tag_to_destroy = tag
      expect do
        delete :destroy, params: { id: tag_to_destroy.id }
        expect(response).to have_http_status(:found)
      end.to change(Decidim::Tags::Tag, :count).by(-1)
    end

    context "when there is an error raised" do
      it "displays an error" do
        allow(Decidim.traceability).to receive(:perform_action!).and_raise("test")

        delete :destroy, params: { id: tag.id }
        expect(flash[:alert]).to be_present
        expect(subject).to redirect_to(tags_path)
      end
    end
  end
end
