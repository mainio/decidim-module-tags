# frozen_string_literal: true

require "spec_helper"

describe Decidim::Tags::TaggingsCommand do
  subject { command_class.new(form, taggable) }

  let(:command_class) do
    concern = described_class
    Class.new(Rectify::Command) do
      include concern

      def initialize(form, taggable)
        @form = form
        @taggable = taggable
      end

      def call
        update_taggings(@taggable, @form)

        broadcast(:ok, @taggable)
      end
    end
  end
  let(:form) do
    Decidim::DummyResources::DummyResourceForm.from_params(
      taggings: { tags: tags.map(&:id) }
    )
  end
  let(:taggable) { create(:dummy_resource) }
  let(:organization) { taggable.component.organization }
  let(:tags) { create_list(:tag, 5, organization: organization) }

  before do
    allow(form).to receive(:organization).and_return(organization)
  end

  describe "update_taggings" do
    it "broadcasts ok and updates the tags" do
      expect { subject.call }.to broadcast(:ok)

      expect(taggable.tags.map(&:id)).to eq(tags.map(&:id))
    end
  end
end
