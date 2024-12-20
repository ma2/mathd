class Ranking < ApplicationRecord
  belongs_to :question

  scope :ranking_by_q, ->(qid) { where(question_id: qid).order(seconds: :asc) }
end
