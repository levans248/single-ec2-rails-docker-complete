class UsersController < ApplicationController
  def index
    @users = User.all
  end

  def new
    @user = User.new
  end

  def create
    User.create(email:params[:user]["email"])
    flash[:new_user] = "Subscribed!"
    redirect_to action: "index"
  end

  private

  def user_params
    params.require(:user).permit(:email)
  end
end
