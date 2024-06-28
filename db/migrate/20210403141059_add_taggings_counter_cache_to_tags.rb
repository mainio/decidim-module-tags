# frozen_string_literal: true

class AddTaggingsCounterCacheToTags < ActiveRecord::Migration[5.2]
  def change
    add_column :decidim_tags_tags, :taggings_count, :integer, null: false, default: 0

    reversible do |dir|
      dir.up do
        Decidim::Tags::Tag.reset_column_information
        Decidim::Tags::Tag.find_each do |tag|
          Decidim::Tags::Tag.reset_counters(tag.id, :taggings)
        end
      end
    end
  end
end
