class CreateKontakti < ActiveRecord::Migration
  def self.up
    create_table :kontakti do |t|
      t.string :ime
      t.string :prezime
      t.string :naziv
      t.integer :vrsta

      t.timestamps
    end
  end

  def self.down
    drop_table :kontakti
  end
end
