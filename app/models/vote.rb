class Vote < ActiveRecord::Base
	# This is Sinatra! Remember to create a migration!
  belongs_to :user

  validates :direction, presence: true, inclusion:{in: %w(UP DOWN), message: "Direction can only be 'UP' or 'DOWN'"}
  validates :user_id, presence: true, uniqueness:{scope: :user_id, message: "Each user can only have 1 vote record on 1 question."}
  validate :validate_self_voting
  # This is Sinatra! Remember to create a migration!

  def is_upvoted_by_self?
    if Vote.where("user_id = ? and question_id = ? and direction = ?", self.user_id, self.question_id, 'UP').length > 0
      return true
    else
      return false
    end
  end

  def is_downvoted_by_self?
    if Vote.where("user_id = ? and question_id = ? and direction = ?", self.user_id, self.question_id, 'DOWN').length > 0
      return true
    else
      return false
    end
  end

  def is_voted_by_self?
    if Vote.where("user_id = ? and question_id = ?", self.user_id, self.question_id).length > 0
      return true
    else
      return false
    end
  end

  private

  def validate_double_voting?
    if self.is_voted_by_self?
      old_vote = Vote.where("user_id = ? and question_id = ?", self.user_id, self.question_id)[0]
      if old_vote.direction == self.direction
        return true
      else
        return false
      end
    end
  end

  def validate_self_voting
    if article.find_by_id(self.question_id).user_id == self.user_id
      errors.add("Cannot vote own question")
    end
  end

  def article
    raise NotImplementedError,
          "This #{self.class} cannot respond to:"
  end

end
