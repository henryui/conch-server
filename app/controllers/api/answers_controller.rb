class Api::AnswersController < ApplicationController
  before_action :authorize
  skip_before_action :verify_authenticity_token

  def index
    if (@answers = Answer.where(user_id: params[:user_id])) && current_user.id == params[:user_id].to_i
      render :json => @answers, status: 200
    else
      render :json => {
        error: 'User is not a mentor with access to this answer',
        status: 403
      }, status: 403
    end
  end

  def create
    @question = Question.find(params[:question_id])
    @mentor_tags = UserTag.where(user_id: current_user.id).map { |x| x.tag_id }
    @question_tags = QuestionTag.where(question_id: params[:question_id]).map { |x| x.tag_id }
    matches = @mentor_tags & @question_tags
    if @question && current_user.is_mentor && current_user.id != @question.user_id && matches.size > 0
      @answer = @question.answers.new(
        user_id: current_user.id,
        content: params[:content],
        selected: false
      )
      if @answer.save
        render :json => @answer, status: 201
      else
        render :json => {
          error: 'Failed to save answer data from the server',
          status: 500
        }, status: 500
      end
    else
      render :json => {
        error: 'User is not a mentor with matching tags',
        status: 403
      }, status: 403
    end
  end

  def show
    @answer = Answer.find(params[:id])
    @question = Question.find(@answer.question_id)
    if current_user.id == @answer.user_id || current_user.id == @question.user_id
      render :json => @answer
    else
      render :json => {
        error: 'Unrelated user to access the answer data',
        status: 403
      }, status: 403
    end
  end

  def update
    @answer = Answer.find(params[:id])
    @question = Question.find(@answer.question_id)
    if current_user.id == @question.user_id
      @answer.update_column(:selected, params[:selected])
      if params[:selected] == 'true'
        @question.update_column(:solved, true)
      else
        @question.update_column(:solved, false)
      end
      render :json => true, status: 200
    else
      render :json => {
        error: 'User is not the owner of the question',
        status: 403
      }, status: 403
    end
  end

  def destroy
  end
end
