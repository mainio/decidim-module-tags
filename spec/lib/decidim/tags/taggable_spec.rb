# frozen_string_literal: true

require "spec_helper"

describe Decidim::Tags::Taggable do
  let!(:tagged_records) { create_list(:dummy_resource, 4, component: component) }
  let!(:other_records) { create_list(:dummy_resource, 10, component: component) }
  let(:component) { create(:component, manifest_name: "dummy", participatory_space: create(:participatory_process, organization: organization)) }
  let(:organization) { create(:organization) }

  let!(:taggings) do
    tagged_records.map do |taggable|
      create(:tagging, taggable: taggable, tag: tags.sample)
    end
  end

  let(:tags) { create_list(:tag, 5, organization: organization) }

  describe ".with_any_tag" do
    subject { Decidim::DummyResources::DummyResource.with_any_tag(*tags) }

    it "returns the tagged records" do
      expect(subject.count).to be(4)
      expect(subject).to match_array(tagged_records)
    end

    context "when passing IDs" do
      subject { Decidim::DummyResources::DummyResource.with_any_tag(*tags.map(&:id)) }

      it "returns the tagged records" do
        expect(subject.count).to be(4)
        expect(subject).to match_array(tagged_records)
      end
    end
  end
end
