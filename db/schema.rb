# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.0].define(version: 2025_01_12_041551) do
  create_table "questions", force: :cascade do |t|
    t.string "date"
    t.string "expression"
    t.integer "value"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "qid"
    t.index ["date"], name: "index_questions_on_date"
    t.index ["qid"], name: "index_questions_on_qid", unique: true
  end

  create_table "rankings", force: :cascade do |t|
    t.string "mondai"
    t.integer "rexp"
    t.string "lexp"
    t.string "hn"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.float "seconds"
    t.integer "question_id", null: false
    t.index ["question_id"], name: "index_rankings_on_question_id"
  end

  create_table "stopwatches", force: :cascade do |t|
    t.boolean "running", default: false, null: false
    t.datetime "started_at"
    t.integer "elapsed_milliseconds", default: 0, null: false
    t.string "anonymous_user_token"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["anonymous_user_token"], name: "index_stopwatches_on_anonymous_user_token", unique: true
  end

  add_foreign_key "rankings", "questions"
end
