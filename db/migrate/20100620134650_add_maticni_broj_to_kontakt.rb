class AddMaticniBrojToKontakt < ActiveRecord::Migration
  def self.up
    add_column :kontakti, :maticni_broj, :string
  end

  def self.down
    remove_column :kontakti, :maticni_broj
  end
end
