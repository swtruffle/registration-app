class StillCompeteForMoney < ActiveRecord::Migration
  def change
  	add_column :users, :still_compete, :string, :limit => 2
  end
end
