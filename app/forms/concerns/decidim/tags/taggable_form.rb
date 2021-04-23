# frozen_string_literal: true

module Decidim
  module Tags
    module TaggableForm
      extend ActiveSupport::Concern

      included do
        attribute :taggings, Decidim::Tags::TaggingsForm
      end
    end
  end
end
