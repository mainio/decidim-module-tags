# frozen_string_literal: true

require "spec_helper"

describe Decidim::Tags::UpdateTaggings do
  let(:form_klass) { Decidim::Tags::TaggingsForm }

  let(:component) { create(:component, manifest_name: "dummy") }
  let(:participatory_space) { component.participatory_space }
  let(:organization) { participatory_space.organization }
  let(:user) { create(:user, :admin, :confirmed, organization: organization) }
  let(:form) do
    form_klass.from_params(
      form_params
    ).with_context(
      current_organization: organization,
      current_user: user
    )
  end

  let(:tags_before) { create_list(:tag, 5, organization: organization) }
  let(:tags_after) { create_list(:tag, 5, organization: organization) }

  let!(:taggable) { create(:dummy_resource, component: component) }

  before do
    taggable.update!(tags: tags_before)
  end

  describe "call" do
    let(:form_params) do
      { tags: tags_after.map(&:id) }
    end

    let(:command) do
      described_class.new(form, taggable)
    end

    describe "when the form is not valid" do
      before do
        expect(form).to receive(:invalid?).and_return(true)
      end

      it "broadcasts invalid" do
        expect { command.call }.to broadcast(:invalid)
      end

      it "doesn't update the taggings" do
        change_eval = lambda {
          Decidim::Tags::Tagging.where(
            taggable: taggable
          ).collect { |pt| pt.tag.id }
        }

        expect { command.call }.not_to(change { change_eval.call })
      end
    end

    describe "when the form is valid" do
      it "broadcasts ok" do
        expect { command.call }.to broadcast(:ok)
      end

      it "updates the taggings" do
        change_eval = lambda {
          Decidim::Tags::Tagging.where(
            taggable: taggable
          ).collect { |pt| pt.tag.id }
        }

        expect { command.call }.to(change { change_eval.call })
      end

      context "with no tags before" do
        let(:tags_before) { [] }

        it "updates the taggings" do
          command.call

          expect(
            Decidim::Tags::Tagging.where(
              taggable: taggable
            ).collect { |pt| pt.tag.id }
          ).to match_array(tags_after.map(&:id))
        end
      end

      context "with no tags after" do
        let(:tags_after) { [] }

        it "updates the taggings" do
          command.call

          expect(
            Decidim::Tags::Tagging.where(
              taggable: taggable
            ).count
          ).to eq(0)
        end
      end
    end
  end
end
