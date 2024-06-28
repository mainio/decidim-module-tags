# frozen_string_literal: true

require "spec_helper"

describe "Taggings" do
  let(:manifest_name) { "dummy" }
  let(:organization) { participatory_process.organization }
  let!(:user) { create(:user, :admin, :confirmed, organization:) }
  let!(:taggable) { create(:dummy_resource, component:) }

  let(:taggings_path) do
    Decidim::EngineRouter.admin_proxy(component).dummy_resource_taggings_path(taggable)
  end

  include_context "when managing a component as an admin"

  describe "editing the resource taggings" do
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

    before do
      taggable.update!(tags: current_tags)
    end

    it "can be updated" do
      visit taggings_path

      # Check and remove current tags
      within "#tags-results" do
        current_tags.each do |tag|
          within ".table-list tbody tr[data-tag-id='#{tag.id}']" do
            expect(page).to have_css("td", text: tag.id)
            expect(page).to have_css("td", text: tag.name["en"])
            find(".remove-tagging").click
          end
        end
      end

      # When all tags are removed, the results should be hidden
      expect(page).to have_css("#tags-results", visible: :hidden)

      # Test autocomplete
      input = find("#add-tags-search input[type='search']")
      input.send_keys("he")

      within ".autoComplete_wrapper" do
        expect(page).to have_css("li", text: "Heinola")
        expect(page).to have_css("li", text: "Helsinki")

        find("li", text: "Helsinki").click
      end

      # Check that the result was added to the list
      within "#tags-results" do
        within ".table-list tr[data-tag-id='#{helsinki_tag.id}']" do
          expect(page).to have_css("td", text: helsinki_tag.id)
          expect(page).to have_css("td", text: "Helsinki")
        end
      end

      within "form.taggings-form" do
        click_on "Update"
      end

      expect(page).to have_content("Dummy index")

      final = Decidim::Dev::DummyResource.find(taggable.id)
      expect(final.tags.map(&:id)).to contain_exactly(helsinki_tag.id)
    end
  end

  describe "creating a new tag from the taggings" do
    it "redirects the user back to taggings after the tag creation" do
      visit taggings_path

      input = find("#add-tags-search input[type='search']")
      input.send_keys("Foobartag")

      within ".autoComplete_wrapper" do
        expect(page).to have_css("div", text: "Foobartag")
        expect(page).to have_content("Create new tag")
        find("a", text: "Foobartag").click
      end

      within "form.tags-form" do
        click_on "Create"
      end

      expect(page).to have_current_path(taggings_path)

      input = find("#add-tags-search input[type='search']")
      input.send_keys("foobar")
      within ".autoComplete_wrapper" do
        expect(page).to have_css("ul li", text: "Foobartag")
      end
    end
  end

  describe "breadcrumbs" do
    context "when the title is translatable" do
      it "displays the translated taggable name" do
        visit taggings_path

        within "#add-tags-search .card-title" do
          expect(page).to have_css("div a", text: taggable.title["en"])
        end
      end
    end

    context "when the title is not translatable" do
      let(:parent) { create(:dummy_resource, component:) }
      let!(:taggable) { create(:nested_dummy_resource, dummy_resource: parent) }

      it "displays the taggable name" do
        visit "#{taggings_path}?nested=1"

        within "#add-tags-search .card-title" do
          expect(page).to have_css("div a", text: taggable.title)
        end
      end
    end
  end
end
