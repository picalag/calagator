class UsersController < ApplicationController
  before_filter :require_no_user, :only => [:new, :create]
  before_filter :require_user, :only => [:show, :edit, :update, :destroy]

  def new
    @user = User.new
  end

  def create
    @user = User.new(params[:user])
    if @user.save
      flash[:notice] = "Account registered!"
      dob = Date.civil(@user.dob.year.to_i,@user.dob.month.to_i,@user.dob.day.to_i)
      arguments = {
        'id_user' => @user.id,
        'male' => @user.male.to_s,
        'dob' => dob.strftime("%Y-%m-%d")
      }
      res = Net::HTTP.post_form(URI.parse(SETTINGS.pserver + '/add_user'), arguments)

      redirect_back_or_default account_url
    else
      render :action => :new
    end
  end

  def show
    @user = @current_user
  end

  def edit
    @user = @current_user
  end

  def update
    @user = @current_user # makes our views "cleaner" and more consistent
    if @user.update_attributes(params[:user])
      flash[:notice] = "Account updated!"
      redirect_to account_url
    else
      render :action => :edit
    end
  end

  # DELETE /users/1
  # DELETE /users/1.xml
  def destroy
    @user = User.find(params[:id])
    current_user_session.destroy
    @user.destroy

    flash[:notice] = "Account de-registered!<br />All personal data has been erased from our databases."
    arguments = {
      'id_user' => params[:id].to_s,
      'male' => 'false',
      'dob' => '0001-01-01'
    }
    res = Net::HTTP.post_form(URI.parse(SETTINGS.pserver + '/add_user'), arguments)

    respond_to do |format|
      format.html { redirect_to(root_url) }
      format.xml  { head :ok }
    end
  end
end
