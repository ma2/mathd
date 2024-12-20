class AddQuestionRefToRankings < ActiveRecord::Migration[8.0]
  def change
    add_reference :rankings, :question, null: false, foreign_key: true
  end
end
