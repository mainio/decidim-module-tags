# frozen_string_literal: true

require "spec_helper"
require "decidim/api/test/type_context"

module Decidim
  module Tags
    describe TagsInterface, type: :graphql do
      include_context "with a graphql class type"

      let(:type_class) { DummyResourceType }
      let(:model) { create(:dummy_resource) }
      let(:tags) { create_list(:tag, 5, organization: model.organization) }

      describe "tags" do
        let(:query) do
          %(
            {
              tags {
                id
                name { translation(locale: "en") }
              }
            }
          )
        end

        before do
          model.update!(tags:)
        end

        it "returns the tags" do
          expect(response["tags"].map { |t| t["id"].to_i }).to match_array(
            tags.map(&:id)
          )
          expect(response["tags"].map { |t| t["name"]["translation"] }).to match_array(
            tags.map { |t| t.name["en"] }
          )
        end
      end
    end
  end
end
