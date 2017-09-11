class Question < ActiveRecord::Base
  belongs_to :user
  has_many :answers
  has_many :question_votes
	# This is Sinatra! Remember to create a migration!
  validates :header, presence: true, length:{maximum: 100, message:"Question header must be less than 100 characters"}
  validates :detail, length:{maximum: 1000, message: "Question detail must be less than 1000 characters"}

  def is_self_vote?(user_id)
    if self[:user_id] == user_id
      return true
    else
      return false
    end
  end

  def ques_upvote_count(ques_id)
    QuestionVote.where("question_id=? and direction = ?", ques_id, 'UP').length
  end

  def ques_downvote_count(ques_id)
    QuestionVote.where("question_id = ? and direction = ?",ques_id, 'DOWN').length
  end

end
