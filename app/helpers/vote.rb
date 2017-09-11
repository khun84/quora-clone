module Vote
  def is_upvoted_by_user?
    if article_vote.where("user_id = ? and article_id = ? and direction = ?", self.user_id, self.article_id, 'UP').length > 0
      return true
    else
      return false
    end
  end

  def is_downvoted_by_user?
    if article_vote.where("user_id = ? and article_id = ? and direction = ?", self.user_id, self.article_id, 'DOWN').length > 0
      return true
    else
      return false
    end
  end

  def is_voted_by_user?
    if article_vote.where("user_id = ? and article_id = ?", self.user_id, self.article_id).length > 0
      return true
    else
      return false
    end
  end

  def article
    raise NotImplementedError,
          "This #{self.class} cannot respond to:"
  end

  def article_vote
    raise NotImplementedError,
          "This #{self.class} cannot respond to:"
  end


  def validate_double_voting
    if self.is_voted_by_user?
      old_vote = article_vote.where("user_id = ? and article_id = ?", self.user_id, self.article_id)[0]
      if old_vote.direction == self.direction
        errors.add(:direction, "Cannot perform the same vote action twice")
      end
    end

  end

  def validate_self_voting
    if article.find_by_id(self.article_id).user_id == self.user_id
      errors.add(:user_id, "Cannot vote own question")
    end
  end
end

helpers do
  def downvoted_by_user?(article_id)
    vote = QuestionVote.new
    vote.article_id = article_id
    vote.user_id = session[:user_id]
    vote.is_downvoted_by_user?
  end
end
