# frozen_string_literal: true

require "spec_helper"

describe "Tags" do
  let(:organization) { create(:organization) }
  let(:user) { create(:user, :confirmed, organization:) }
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
            #{javascript_pack_tag "decidim_core", defer: false}
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
      allow(Decidim::Tags::FormCell).to receive(:tag_options)
        .and_return(all_tags)

      final_html = html_document
      favicon = ""

      Rails.application.routes.draw do
        mount Decidim::Api::Engine => "/api"

        get "test_tags", to: ->(_) { [200, {}, [final_html]] }
        get "/favicon.ico", to: ->(_) { [200, {}, [favicon]] }
      end
    end

    after do
      Rails.application.reload_routes!
    end
  end

  describe "form" do
    include_context "with a plain HTML page"

    let(:helsinki_tag) do
      create(:tag, name: { en: "Helsinki" }, organization:)
    end
    let!(:other_tags) do
      [
        helsinki_tag,
        create(:tag, name: { en: "Heinola" }, organization:),
        create(:tag, name: { en: "Hollola" }, organization:),
        create(:tag, name: { en: "Jämijärvi" }, organization:),
        create(:tag, name: { en: "Jämsä" }, organization:),
        create(:tag, name: { en: "Järvenpää" }, organization:)
      ]
    end
    let(:current_tags) { create_list(:tag, 5, organization:) }
    let(:all_tags) { other_tags + current_tags }
    let(:form) do
      Decidim::Dev::DummyResourceForm.from_params(
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
            context: { view_context: self, controller: }
          ).call.to_s
        end
      end
    end

    it "can use the tagging input" do
      visit "/test_tags"
      expect_no_js_errors

      input = find_by_id("tags_list")

      puts "#{page.driver.browser.logs.get(:browser)}errors "

      within input do
        current_tags.each do |tag|
          expect(page).to have_css("option", text: tag.name["en"])
        end
      end
      within ".row.column" do
        current_tags.each do |tag|
          expect(page).to have_css(
            "input[name='dummy_resource[taggings][tags][]'][value='#{tag.id}']", visible: :hidden
          )

          expect(page).to have_css(
            "div.ts-control div.item[data-value='#{tag.id}']", text: tag.name["en"]
          )
        end
      end

      search_input = find_by_id("tags_list-ts-control")
      search_input.send_keys("he")

      within ".ts-dropdown-content#tags_list-ts-dropdown" do
        expect(page).to have_css("div.option", text: "Helsinki")
        expect(page).to have_css("div.option", text: "Heinola")
        expect(page).to have_no_css("div.option", text: "Hollola")

        find("div.option", text: "Helsinki").click
      end
      within input do
        expect(page).to have_css("option", text: "Helsinki")
      end

      search_input.send_keys([:backspace], [:backspace])
      search_input.send_keys("h")
      within ".ts-dropdown-content#tags_list-ts-dropdown" do
        expect(page).to have_no_css("div.option", text: "Helsinki")
        expect(page).to have_css("div.option", text: "Heinola")
        expect(page).to have_css("div.option", text: "Hollola")
      end

      # Remove "Helsinki" with sending backspaces
      search_input.send_keys([:backspace], [:backspace], [:backspace])
      within input do
        expect(page).to have_no_css(".label .tag-name", text: "Helsinki")
      end

      search_input.send_keys("foo")
      within ".ts-dropdown-content#tags_list-ts-dropdown" do
        expect(page).to have_css("div.no-results", text: "No tags available.")
      end
    end
  end

  describe "tags" do
    include_context "with a plain HTML page"

    let(:participatory_space) { create(:participatory_process, organization:) }
    let(:component) { create(:component, manifest_name: "dummy", participatory_space:) }
    let(:taggable) do
      resource = create(:dummy_resource, component:)
      resource.update!(tags: current_tags)
      resource
    end
    let(:current_tags) { create_list(:tag, 5, organization:) }
    let(:all_tags) { current_tags }
    let(:html_body) do
      resource = taggable
      template.instance_eval do
        Decidim::ViewModel.cell(
          "decidim/tags/tags",
          resource,
          context: { controller: }
        ).call.to_s
      end
    end

    it "displays the tags" do
      visit "/test_tags"

      current_tags.each do |tag|
        expect(page).to have_css(".label", text: tag.name["en"])
      end
    end
  end
end
