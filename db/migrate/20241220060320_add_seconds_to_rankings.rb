class AddSecondsToRankings < ActiveRecord::Migration[8.0]
  def change
    add_column :rankings, :seconds, :float
  end
end
