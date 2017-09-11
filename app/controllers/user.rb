post '/users/signup' do
  @user = User.new(user_id:params[:email], password:params[:password], password_confirmation: false)
  if @user.save
    session[:user_id] = @user[:id]
    redirect "/users/#{@user[:id]}"
  else
    # return the error message
    @messages = @user.errors.messages
    erb :"static/landing"

  end
end

post '/users/login' do
  @user = User.find_by(user_id: params[:email]).try(:authenticate, params[:password])
  if @user
    session[:user_id] = @user[:id]
    redirect "/questions/index"
  else
    @messages = {Invalid_login: ['Wrong username or password']}
    erb :"static/landing"
  end
end

get '/users/logout' do
  session[:user_id] = nil
  redirect '/'
end

get '/users/:id' do
  if logged_in?
    @user = User.find_by_id(params[:id])
    erb :"user/profile"
  else
    erb :"static/landing"
  end
end

get '/users/:id/questions' do
  if logged_in?
    user = User.find_by_id(params[:id])
    questions = user.questions.order(:id).reverse_order

    if !questions.nil?
      response = Array.new
      questions.each do |ques|
        response << ques.attributes
      end
      return response.to_json
    end

  else
    erb :"static/landing"
  end
end

get '/users/:id/answers' do
  if logged_in?
    user = User.find_by_id(params[:id])
    answers = user.answers.order(:id).reverse_order

    if !answers.nil?
      response = Array.new
      answers.each do |ans|
        response << ans.attributes
      end
      return response.to_json
    end

  else
    erb :"static/landing"
  end
end

get '/users/:user_id/questions/:ques_id/upvote' do
  if logged_in?
    # assuming the question being voted always exists

    if !is_voted?(params[:user_id], params[:ques_id])
      upvote = QuestionVote.new
      upvote[:user_id] = params[:user_id]
      upvote[:article_id] = params[:ques_id]
      upvote[:direction] = 'UP'

      if upvote.save
        return {upvote_count: ques_upvote_count(params[:ques_id])}.to_json
      else
        errors = flag_error_msg(upvote.errors.messages)
        return errors.to_json
      end
    end

    if !is_upvoted(params[:user_id], params[:ques_id])
      upvote = QuestionVote.where("user_id = ? and question_id = ?", params[:user_id], params[:ques_id])[0]

      upvote.direction = 'UP'

      if upvote.save
        return {upvote_count: ques_upvote_count(params[:ques_id])}.to_json
      else
        errors = flag_error_msg(upvote.errors.messages)
        return erros.to_json
      end
    else
      errors = {double_vote: ["Can only upvote once for each question!"]}.to_json
      return errors
    end

  else
    erb :'static/landing'
  end
end

get '/questions/:ques_id/downvote' do
  if logged_in?
    # assuming the question being voted always exists
    params[:user_id] = session[:user_id]
    downvote = QuestionVote.new
    downvote[:user_id] = params[:user_id]
    downvote[:article_id] = params[:ques_id]
    downvote[:direction] = 'DOWN'

    question = Question.find_by_id(params[:ques_id])

    if downvote.is_voted_by_user?
      downvote = QuestionVote.where("user_id = ? and article_id = ?", downvote[:user_id], downvote[:article_id])[0]
      previous_direction = downvote.direction
      downvote.direction = "DOWN" if downvote.direction != "DOWN"
      if downvote.is_downvoted_by_user?
        # delete the vote if its a repeated vote action
        downvote.destroy
        question.reduce_downvote
      end

    else

      # save the downvote create or edit action
      if !downvote.save
        errors = flag_error_msg(downvote.errors.messages)
        return errors.to_json
      else
        question.add_downvote
      end
    end


    if question.save
      return {downvote_count: question.downvote_count}.to_json
    else

      if previous_direction.nil?
      # reverse the vote create action
        downvote.destroy
      else
      # reverse the vote edit action
        downvote.direction = previous_direction
        downvote.save
      end
      errors = flag_error_msg(downvote.errors.messages)
      return errors.to_json
    end

  else
    erb :'static/landing'
  end
end
