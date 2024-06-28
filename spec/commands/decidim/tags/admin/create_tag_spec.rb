# frozen_string_literal: true

require "spec_helper"

describe Decidim::Tags::Admin::CreateTag do
  let(:form_klass) { Decidim::Tags::Admin::TagForm }

  let(:organization) { create(:organization) }
  let(:user) { create(:user, :admin, :confirmed, organization:) }
  let(:form) do
    form_klass.from_params(
      form_params
    ).with_context(
      current_organization: organization,
      current_user: user
    )
  end

  describe "call" do
    let(:form_params) do
      {
        name: { en: "A new tag" }
      }
    end

    let(:command) { described_class.new(form) }

    describe "when the form is not valid" do
      before do
        allow(form).to receive(:invalid?).and_return(true)
      end

      it "broadcasts invalid" do
        expect { command.call }.to broadcast(:invalid)
      end

      it "doesn't create a tag" do
        expect do
          command.call
        end.not_to change(Decidim::Tags::Tag, :count)
      end
    end

    describe "when the form is valid" do
      it "broadcasts ok" do
        expect { command.call }.to broadcast(:ok)
      end

      it "creates a new tag" do
        expect do
          command.call
        end.to change(Decidim::Tags::Tag, :count).by(1)
      end
    end
  end
end
