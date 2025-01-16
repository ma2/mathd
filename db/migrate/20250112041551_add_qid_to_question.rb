class AddQidToQuestion < ActiveRecord::Migration[8.0]
  def change
    add_column :questions, :qid, :string
    add_index  :questions, :qid, unique: true
  end
end
