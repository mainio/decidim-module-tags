# frozen_string_literal: true

module Decidim
  module Tags
    # A command with all the business logic when a user updates taggings.
    class UpdateTaggings < Rectify::Command
      # Public: Initializes the command.
      #
      # form - A form object with the params.
      # taggable - The target object to be updated.
      def initialize(form, taggable)
        @form = form
        @taggable = taggable
      end

      # Executes the command. Broadcasts these events:
      #
      # - :ok when everything is valid, together with the plan.
      # - :invalid if the form wasn't valid and we couldn't proceed.
      #
      # Returns nothing.
      def call
        return broadcast(:invalid) if form.invalid?

        update_taggings

        broadcast(:ok, taggable)
      end

      private

      attr_reader :form, :taggable

      def update_taggings
        tagger = Tagger.new(
          taggable: taggable,
          organization: form.organization
        )
        tagger.apply(form.tags)
      end
    end
  end
end
