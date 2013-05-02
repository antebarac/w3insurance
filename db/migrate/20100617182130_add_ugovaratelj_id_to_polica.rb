class AddUgovarateljIdToPolica < ActiveRecord::Migration
  def self.up
    add_column :police, :ugovaratelj_id, :integer
  end

  def self.down
    remove_column :police, :ugovaratelj_id
  end
end
