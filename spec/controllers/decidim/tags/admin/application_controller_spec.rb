# frozen_string_literal: true

require "spec_helper"

describe Decidim::Tags::Admin::ApplicationController do
  describe "#permission_class_chain" do
    it "includes the tags admin permission class" do
      expect(subject.send(:permission_class_chain)).to include(Decidim::Tags::Admin::Permissions)
    end
  end
end
