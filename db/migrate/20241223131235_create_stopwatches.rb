class CreateStopwatches < ActiveRecord::Migration[8.0]
  def change
    create_table :stopwatches do |t|
      t.boolean :running, default: false, null: false
      t.datetime :started_at
      t.integer :elapsed_milliseconds, default: 0, null: false
      t.string :anonymous_user_token, index: { unique: true }

      t.timestamps
    end
  end
end
