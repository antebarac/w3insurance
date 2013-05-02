class AddOibToKontakt < ActiveRecord::Migration
  def self.up
    add_column :kontakti, :oib, :string
  end

  def self.down
    remove_column :kontakti, :oib
  end
end
