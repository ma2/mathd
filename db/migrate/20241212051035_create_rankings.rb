class CreateRankings < ActiveRecord::Migration[8.0]
  def change
    create_table :rankings do |t|
      t.string :mondai
      t.integer :rexp
      t.string :lexp
      t.string :hn

      t.timestamps
    end
  end
end
