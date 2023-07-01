# frozen_string_literal: true

require "spec_helper"
require "decidim/api/test/type_context"

module Decidim
  module Tags
    describe TagType do
      include_context "with a graphql class type"
      let(:model) { create(:tag, organization: current_organization) }

      describe "id" do
        let(:query) { "{ id }" }

        it "returns the tag's id" do
          expect(response["id"]).to eq(model.id.to_s)
        end
      end

      describe "name" do
        let(:query) { '{ name { translation(locale: "en") } }' }

        it "returns the tag's name" do
          expect(response["name"]["translation"]).to eq(model.name["en"])
        end
      end
    end
  end
end
