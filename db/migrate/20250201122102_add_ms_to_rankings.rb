class AddMsToRankings < ActiveRecord::Migration[8.0]
  def change
    add_column :rankings, :ms, :integer
    remove_column :rankings, :mondai
    remove_column :rankings, :rexp
  end
end
