class AddWebsiteAndReservationDetailsAndPriceToEvents < ActiveRecord::Migration
  def self.up
    add_column :events, :price, :string
    add_column :events, :reservation_details, :string
    add_column :events, :website, :string
  end

  def self.down
    remove_column :events, :price
    remove_column :events, :reservation_details
    remove_column :events, :website
  end
end
