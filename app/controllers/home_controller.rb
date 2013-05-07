class HomeController < ApplicationController
  def index
    unless session[:current_user].nil?
    	redirect_to faqs_path
    else
  		@user = User.new
  	end
  end
  
  def login
	  @user = User.new(params[:user])
	  current_user = User.find_by_username(@user.username)
			unless current_user.nil?
			  if @user.password == current_user.password
			  	session[:current_user] = @user.username
			  	redirect_to faqs_path
			  else
			  	redirect_to :back, :notice=>"密码错误!"
			  end
			else
		  	redirect_to :back, :notice=>"用户名错误!"
			end
	 end

  def logout
    session[:current_user] = nil
    session[:enabled] = nil
  	session[:disabled] = nil
    @user = User.new
    render :index
  end

end
