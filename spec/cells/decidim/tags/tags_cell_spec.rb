# frozen_string_literal: true

require "spec_helper"

describe Decidim::Tags::TagsCell, type: :cell do
  subject { cell("decidim/tags/tags", taggable).call }

  controller Decidim::ApplicationController

  let(:taggable) { create(:dummy_resource) }
  let(:organization) { taggable.component.organization }
  let(:tags) { create_list(:tag, 5, organization: organization) }

  before do
    taggable.update!(tags: tags)
  end

  it "displays the tags" do
    tags.each do |tag|
      expect(subject).to have_selector(".label", text: tag.name["en"])
    end
  end

  context "when there are no tags" do
    let(:tags) { [] }

    it "does not display anything" do
      expect(subject).not_to have_selector(".label")
    end
  end
end
