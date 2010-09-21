class AddExcerptAndGalleryIdToEvents < ActiveRecord::Migration
  def self.up
    add_column :events, :excerpt, :string
    add_column :events, :base_gallery_id, :integer
  end

  def self.down
    remove_column :events, :excerpt
    remove_column :events, :base_gallery_id
  end
end
