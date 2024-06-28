# frozen_string_literal: true

require "spec_helper"

describe Decidim::Tags::Tagger do
  subject do
    described_class.new(taggable:, organization:)
  end

  let(:taggable) { create(:dummy_resource) }
  let(:organization) { taggable.component.organization }
  let(:tags) { create_list(:tag, 5, organization:) }

  it "tags the given resource" do
    subject.apply(tags.map(&:id))

    expect(taggable.tags.map(&:id)).to match_array(tags.map(&:id))
  end

  context "when updating tags" do
    let(:tags_before) { create_list(:tag, 3, organization:) }
    let(:final) { Decidim::Dev::DummyResource.find(taggable.id) }

    before do
      taggable.update!(tags: tags_before)
    end

    it "updates the tags for the given resource" do
      subject.apply(tags.map(&:id))

      expect(final.tags.map(&:id)).to match_array(tags.map(&:id))
    end

    context "with an empty tags ID array" do
      it "removes all the taggings" do
        subject.apply([])

        expect(final.tags).to be_empty
      end
    end
  end
end
