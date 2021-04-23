# frozen_string_literal: true

require "decidim/core/test/factories"
require "decidim/dev/test/factories"

FactoryBot.define do
  factory :tag, class: "Decidim::Tags::Tag" do
    organization { build(:organization) }
    name { Decidim::Faker::Localized.localized { Faker::Lorem.word.capitalize } }
  end

  factory :tagging, class: "Decidim::Tags::Tagging" do
    taggable { build(:dummy_resource) }
    tag { build(:tag) }
  end
end
