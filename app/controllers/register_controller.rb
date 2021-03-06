class RegisterController < ApplicationController
  skip_before_action :verify_authenticity_token

  def create
    session[:user_id] = nil
    @user = User.new(user_params)
    @user[:points] = 0
    @user[:is_mentor] = false

    if User.where(email: params[:email]).size > 0
      render :json => {
        error: 'Email already exists',
        status: 400
      }, status: 400
    else
      if @user.save
        session[:user_id] = @user.id
        render :json => @user, status: 200
      else
        render :json => {
          error: 'Failed to create user data from the server',
          status: 500
        }, status: 500
      end
    end
  end

  private

  def user_params
    params.permit(
      :nickname,
      :email,
      :password
    )
  end
end
