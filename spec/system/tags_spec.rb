# frozen_string_literal: true

require "spec_helper"

describe "Tags views", type: :system do
  let(:organization) { create(:organization) }
  let(:user) { create(:user, :confirmed, organization: organization) }
  let(:dummy_resource) { create(:dummy_resource) }

  before do
    switch_to_host(organization.host)
    login_as user, scope: :user
  end

  shared_context "with a plain HTML page" do
    let(:html_body) { "" }

    let(:html_document) do
      document_inner = html_body
      template.instance_eval do
        <<~HTML.strip
          <!doctype html>
          <html lang="en">
          <head>
            <title>Tags Test</title>
            #{stylesheet_pack_tag "decidim_core"}
            #{javascript_pack_tag "decidim_core"}
            #{snippets.display(:head)}
          </head>
          <body>
            #{document_inner}
          </body>
          </html>
        HTML
      end
    end
    let(:template_class) do
      Class.new(ActionView::Base) do
        delegate :snippets, to: :controller

        def protect_against_forgery?
          false
        end

        def controller
          @controller ||= controller_class.new
        end

        def controller_class
          Class.new(ApplicationController) do
            include Decidim::NeedsSnippets
          end
        end
      end
    end
    let(:template) { template_class.new(ActionView::LookupContext.new(ActionController::Base.view_paths), {}, []) }

    before do
      allow(template.controller).to receive(:current_organization).and_return(organization)

      final_html = html_document
      Rails.application.routes.draw do
        mount Decidim::Api::Engine => "/api"

        get "test_tags", to: ->(_) { [200, {}, [final_html]] }
      end
    end

    after do
      Rails.application.reload_routes!
    end
  end

  describe "form" do
    include_context "with a plain HTML page"

    let(:helsinki_tag) do
      create(:tag, name: { en: "Helsinki" }, organization: organization)
    end
    let!(:other_tags) do
      [
        helsinki_tag,
        create(:tag, name: { en: "Heinola" }, organization: organization),
        create(:tag, name: { en: "Hollola" }, organization: organization),
        create(:tag, name: { en: "Jämijärvi" }, organization: organization),
        create(:tag, name: { en: "Jämsä" }, organization: organization),
        create(:tag, name: { en: "Järvenpää" }, organization: organization)
      ]
    end
    let(:current_tags) { create_list(:tag, 5, organization: organization) }
    let(:form) do
      Decidim::DummyResources::DummyResourceForm.from_params(
        taggings: { tags: current_tags.map(&:id) }
      )
    end
    let(:html_body) do
      form_object = form
      template.instance_eval do
        form_for(form_object, url: "/") do |form|
          Decidim::ViewModel.cell(
            "decidim/tags/form",
            form,
            context: { controller: controller }
          ).call.to_s
        end
      end
    end

    it "can use the tagging input" do
      visit "/test_tags"
      expect_no_js_errors

      input = find("#dummy_resource_taggings_tags")
      within input do
        current_tags.each do |tag|
          expect(page).to have_selector(".label .tag-name", text: tag.name["en"])
        end
      end
      within ".js-tags-input" do
        current_tags.each do |tag|
          expect(page).to have_selector(
            "input[name='dummy_resource[taggings][tags][]'][value='#{tag.id}'][data-tag-name='#{CGI.escapeHTML(tag.name["en"])}']",
            visible: :hidden
          )
        end
      end

      input.send_keys("he")
      within ".js-tags-input .autocomplete #results" do
        expect(page).to have_selector("li", text: "Helsinki")
        expect(page).to have_selector("li", text: "Heinola")
        expect(page).not_to have_selector("li", text: "Hollola")

        find("li", text: "Helsinki").click
      end
      within input do
        expect(page).to have_selector(".label .tag-name", text: "Helsinki")
      end
      within ".js-tags-input" do
        expect(page).to have_selector(
          "input[name='dummy_resource[taggings][tags][]'][value='#{helsinki_tag.id}'][data-tag-name='Helsinki']",
          visible: :hidden
        )
      end

      input.send_keys("h")
      within ".js-tags-input .autocomplete #results" do
        expect(page).not_to have_selector("li", text: "Helsinki")
        expect(page).to have_selector("li", text: "Heinola")
        expect(page).to have_selector("li", text: "Hollola")
      end

      # Remove "Helsinki" with sending backspaces
      input.send_keys([:backspace], [:backspace], [:backspace])
      within input do
        expect(page).not_to have_selector(".label .tag-name", text: "Helsinki")
      end

      input.send_keys("foo")
      within ".js-tags-input .autocomplete #results" do
        expect(page).to have_selector("li", text: "No tags available.")
      end
    end
  end

  describe "tags" do
    include_context "with a plain HTML page"

    let(:participatory_space) { create(:participatory_process, organization: organization) }
    let(:component) { create(:component, manifest_name: "dummy", participatory_space: participatory_space) }
    let(:taggable) do
      resource = create(:dummy_resource, component: component)
      resource.update!(tags: current_tags)
      resource
    end
    let(:current_tags) { create_list(:tag, 5, organization: organization) }
    let(:html_body) do
      resource = taggable
      template.instance_eval do
        Decidim::ViewModel.cell(
          "decidim/tags/tags",
          resource,
          context: { controller: controller }
        ).call.to_s
      end
    end

    it "displays the tags" do
      visit "/test_tags"

      current_tags.each do |tag|
        expect(page).to have_selector(".label", text: tag.name["en"])
      end
    end
  end
end
