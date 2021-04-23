# frozen_string_literal: true

require "spec_helper"

describe Decidim::Tags::ComponentRecordTags do
  subject { query_class.new(component) }

  let(:query_class) do
    Class.new(described_class) do
      taggable Decidim::DummyResources::DummyResource
    end
  end

  let(:organization) { create(:organization) }

  let(:component) { create(:dummy_component, organization: organization) }
  let(:other_component) { create(:dummy_component, organization: organization) }

  let(:tags) { create_list(:tag, 5, organization: organization) }
  let(:other_tags) { create_list(:tag, 3, organization: organization) }

  let!(:taggables) { create_list(:dummy_resource, 5, component: component) }
  let!(:other_taggables) { create_list(:dummy_resource, 6, component: other_component) }
  let!(:other_taggables_same_tags) { create_list(:dummy_resource, 6, component: other_component) }

  before do
    taggables.each do |taggable|
      taggable.update!(tags: tags)
    end
    other_taggables.each do |taggable|
      taggable.update!(tags: other_tags)
    end
    other_taggables_same_tags.each do |taggable|
      taggable.update!(tags: tags)
    end
  end

  it "returns records included in the organization" do
    expect(subject).to match_array(tags)
  end

  context "with taggable class not defined" do
    let(:query_class) { described_class }

    it "raises an error" do
      expect { subject.query }.to raise_error(NotImplementedError)
    end
  end
end
