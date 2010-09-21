class ChangeExcerptFieldTypeAddHtmlToEvents < ActiveRecord::Migration
  def self.up
    change_column :events, :excerpt, :text
    add_column :events, :excerpt_html, :text
  end

  def self.down
    change_column :events, :excerpt, :string
    remove_column :events, :excerpt_html
  end
end
