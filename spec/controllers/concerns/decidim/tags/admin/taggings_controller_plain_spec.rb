# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Tags
    module Admin
      describe "TaggingsControllerPlain" do
        controller do
          include Decidim::FormFactory
          include Decidim::Tags::Admin::TaggingsController
        end

        let(:organization) { create(:organization) }
        let(:user) { create(:user, :admin, :confirmed, organization:) }

        before do
          request.env["decidim.current_organization"] = organization
          sign_in user, scope: :user

          routes.draw do
            get "show" => "anonymous#show"
          end
        end

        describe "GET show" do
          it "raises an error without a taggable resource defined" do
            expect { get :show }.to raise_error(NotImplementedError)
          end
        end
      end
    end
  end
end
