class CreatePolice < ActiveRecord::Migration
  def self.up
    create_table :police do |t|
      t.datetime :traje_od
      t.datetime :traje_do
      t.string :broj

      t.timestamps
    end
  end

  def self.down
    drop_table :police
  end
end
