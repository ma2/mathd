class CreateQuestions < ActiveRecord::Migration[8.0]
  def change
    create_table :questions do |t|
      t.string :date
      t.string :expression
      t.integer :value

      t.timestamps
    end
    add_index :questions, :date
  end
end
