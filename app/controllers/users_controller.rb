class UsersController < ApplicationController

  # display the signup form
  def new
    @user = User.new
  end

  # create a new user from the registation/sign in form
  def create
    @user = User.new(user_params)
    if @user.save
      flash[:notice] = "Thanks for signing up"
      redirect_to root_url
    else
      render 'new'
    end
  end

  private

  def user_params
    #params = {:tools => {:id =33, :name => 'wrench'}
    params.require(:user).permit(:email, :password) #, :password_confirmation)
  end
end