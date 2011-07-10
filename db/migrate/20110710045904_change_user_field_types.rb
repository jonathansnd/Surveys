class ChangeUserFieldTypes < ActiveRecord::Migration
  def self.up
  	change_column :users, :active, :boolean
  	change_column :users, :utcOffset, :integer
  end

  def self.down
  	change_column :users, :active, :string
  	change_column :users, :utcOffset, :string
  end
end
