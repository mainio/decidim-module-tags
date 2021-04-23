# frozen_string_literal: true

require "spec_helper"

describe Decidim::Tags::FormCell, type: :cell do
  subject do
    form_object = form
    cell_options = options
    html = template.instance_eval do
      form_for(form_object, url: "/") do |form|
        cell(
          "decidim/tags/form",
          form,
          cell_options
        ).call
      end
    end
    Capybara::Node::Simple.new(html)
  end

  controller Decidim::ApplicationController

  let(:options) { {} }
  let(:taggable) { create(:dummy_resource) }
  let(:organization) { taggable.component.organization }
  let(:tags) { create_list(:tag, 5, organization: organization) }

  let(:form) do
    Decidim::DummyResources::DummyResourceForm.from_params(
      taggings: { tags: tags.map(&:id) }
    )
  end
  let(:template_class) do
    Class.new(ActionView::Base) do
      delegate :snippets, to: :controller

      def protect_against_forgery?
        false
      end
    end
  end
  let(:template) { template_class.new }

  before do
    taggable.update!(tags: tags)

    allow(template).to receive(:controller).and_return(controller)
  end

  it "displays the existing tags and their hidden inputs" do
    expect(subject).to have_selector("label", text: "Tags")

    tags.each do |tag|
      within ".input-tags" do
        expect(subject).to have_selector(".label", text: tag.name["en"])
      end

      within ".js-tags-input" do
        expect(page).to have_selector(
          "input[name='dummy_resource[taggings][tags][]'][value='#{tag.id}'][data-tag-name='#{CGI.escapeHTML(tag.name["en"])}']",
          visible: :hidden
        )
      end
    end
  end

  context "when the label option is set to false" do
    let(:options) { { label: false } }

    it "does not display the label" do
      expect(subject).not_to have_selector("label")
    end
  end

  context "when the label option is set to custom text" do
    let(:options) { { label: "Custom" } }

    it "displays the custom label" do
      expect(subject).to have_selector("label", text: "Custom")
    end
  end

  context "when there are no tags" do
    let(:tags) { [] }

    it "does not display any existing tags" do
      within ".input-tags" do
        expect(subject).not_to have_selector(".label")
      end

      within ".js-tags-input" do
        expect(subject).not_to have_selector(input, visible: :hidden)
      end
    end
  end
end
