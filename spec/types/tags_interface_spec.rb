# frozen_string_literal: true

require "spec_helper"
require "decidim/api/test/type_context"

module Decidim
  module Tags
    describe TagsInterface do
      include_context "with a graphql type"

      let(:type_class) { Decidim::Core::ComponentType }
      let(:schema) { Decidim::Api::Schema }
      let(:response) do
        actual_query = %(
          {
            dummy(id: "#{model.id}") #{query}
          }
        )
        resp = execute_query actual_query, variables.stringify_keys
        resp["dummy"]["tags"]
      end
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
          model.update!(tags: tags)
        end

        it "returns the tags" do
          expect(response.map { |t| t["id"].to_i }).to match_array(
            tags.map(&:id)
          )
          expect(response.map { |t| t["name"]["translation"] }).to match_array(
            tags.map { |t| t.name["en"] }
          )
        end
      end
    end
  end
end
