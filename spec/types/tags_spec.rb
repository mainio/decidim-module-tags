# frozen_string_literal: true

require "spec_helper"
require "decidim/api/test/type_context"

describe "Decidim::Api::QueryType" do
  include_context "with a graphql type"
  let(:schema) { Decidim::Api::Schema }

  let(:locale) { "en" }

  let(:query) do
    %(
      query {
        tags{
          id
          name {
            translations {
              text
              locale
            }
          }
        }
      }
    )
  end

  describe "valid query" do
    it "executes sucessfully" do
      expect { response }.not_to raise_error
    end

    context "when there are no tags" do
      it "has an empty tags node" do
        expect(response["tags"]).to eq([])
      end
    end

    context "when there are tags in multiple organizations" do
      let(:other_organization) { create(:organization) }
      let!(:correct_tags) { create_list(:tag, 5, organization: current_organization) }
      let!(:incorrect_tags) { create_list(:tag, 5, organization: other_organization) }

      it "has returns the tags in current organization" do
        expect(response["tags"].map { |t| t["id"].to_i }).to match_array(correct_tags.map(&:id))
        expect(
          response["tags"].map do |t|
            t["name"]["translations"].find { |tr| tr["locale"] == "en" }["text"]
          end
        ).to match_array(correct_tags.map { |t| t.name["en"] })
      end
    end
  end
end
