class Question < ActiveRecord::Base
  belongs_to :user
  has_many :answers
  has_many :question_votes
	# This is Sinatra! Remember to create a migration!
  validates :header, presence: true, length:{maximum: 100, message:"Question header must be less than 100 characters"}
  validates :detail, length:{maximum: 1000, message: "Question detail must be less than 1000 characters"}
  validates :downvote_count, numericality:{greater_than_or_equal_to: 0}
  validates :upvote_count, numericality:{greater_than_or_equal_to: 0}

  def is_self_vote?(user_id)
    if self[:user_id] == user_id
      return true
    else
      return false
    end
  end

  def reduce_downvote
    self.downvote_count-= downvote_weight
  end

  def add_downvote
    self.downvote_count+= downvote_weight
  end

  def reduce_upvote
    self.upvote_count-= upvote_weight
  end

  def add_upvote
    self.upvote_count+= upvote_weight
  end

  def downvote_weight
    1
  end

  def upvote_weight
    1
  end

  def self.ques_upvote_count(ques_id)
    QuestionVote.where("article_id=? and direction = ?", ques_id, 'UP').length
  end

  def self.ques_downvote_count(ques_id)
    QuestionVote.where("article_id = ? and direction = ?",ques_id, 'DOWN').length
  end

end
