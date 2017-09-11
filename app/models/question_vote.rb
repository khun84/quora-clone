# require '../../app/helpers/vote'

class QuestionVote < ActiveRecord::Base
  include Vote

  belongs_to :user
  belongs_to :question, foreign_key: :article_id

	# This is Sinatra! Remember to create a migration!
  validates :direction, presence: true, inclusion:{in: %w(UP DOWN), message: "Direction can only be 'UP' or 'DOWN'"}
  validates :user_id, presence: true, uniqueness:{scope: :user_id, message: "Each user can only have 1 vote record on 1 question."}
  validate :validate_self_voting

  def article
    return Question
  end

  def article_vote
    return QuestionVote
  end
end
